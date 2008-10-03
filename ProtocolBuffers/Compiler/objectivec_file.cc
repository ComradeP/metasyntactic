// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.
// http://code.google.com/p/protobuf/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: kenton@google.com (Kenton Varda)
//  Based on original Protocol Buffers design by
//  Sanjay Ghemawat, Jeff Dean, and others.

#include <google/protobuf/compiler/objectivec/objectivec_file.h>
#include <google/protobuf/compiler/objectivec/objectivec_enum.h>
#include <google/protobuf/compiler/objectivec/objectivec_service.h>
#include <google/protobuf/compiler/objectivec/objectivec_extension.h>
#include <google/protobuf/compiler/objectivec/objectivec_helpers.h>
#include <google/protobuf/compiler/objectivec/objectivec_message.h>
#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>

namespace google { namespace protobuf { namespace compiler {namespace objectivec {

  FileGenerator::FileGenerator(const FileDescriptor* file)
    : file_(file),
    classname_(FileClassName(file)) {}

  FileGenerator::~FileGenerator() {}

  bool FileGenerator::Validate(string* error) {
    // Check that no class name matches the file's class name.  This is a common
    // problem that leads to ObjectiveC compile errors that can be hard to understand.
    // It's especially bad when using the objectivec_multiple_files, since we would
    // end up overwriting the outer class with one of the inner ones.

    bool found_conflict = false;
    for (int i = 0; i < file_->enum_type_count() && !found_conflict; i++) {
      if (ClassName(file_->enum_type(i)) == classname_) {
        found_conflict = true;
      }
    }
    for (int i = 0; i < file_->message_type_count() && !found_conflict; i++) {
      if (ClassName(file_->message_type(i)) == classname_) {
        found_conflict = true;
      }
    }
    for (int i = 0; i < file_->service_count() && !found_conflict; i++) {
      if (ClassName(file_->service(i)) == classname_) {
        found_conflict = true;
      }
    }

    if (found_conflict) {
      error->assign(file_->name());
      error->append(
        ": Cannot generate ObjectiveC output because the file's outer class name, \"");
      error->append(classname_);
      error->append(
        "\", matches the name of one of the types declared inside it.  "
        "Please either rename the type or use the objectivec_outer_classname "
        "option to specify a different outer class name for the .proto file.");
      return false;
    }

    return true;
  }

  void FileGenerator::GenerateHeader(io::Printer* printer) {
    // We don't import anything because we refer to all classes by their
    // fully-qualified names in the generated source.
    printer->Print(
      "// Generated by the protocol buffer compiler.  DO NOT EDIT!\n\n");

    // hacky.  but this is how other generators determine if we're generating
    // the core ProtocolBuffers library
    if (file_->name() != "google/protobuf/descriptor.proto") {
      //printer->Print("#import <ProtocolBuffers/ProtocolBuffers.h>\n\n");
    }

    if (file_->dependency_count() > 0) {
      for (int i = 0; i < file_->dependency_count(); i++) {
        printer->Print(
          "#import \"$header$.pb.h\"\n",
          "header", FilePath(file_->dependency(i)));
      }
      printer->Print("\n");
    }

    printer->Print(
      "@class PBFieldAccessorTable;\n"
      "@class PBGeneratedMessage_Builder;\n");

    set<string> dependencies;
    DetermineDependencies(&dependencies);
    for (set<string>::const_iterator i(dependencies.begin()); i != dependencies.end(); ++i) {
      printer->Print(
        "@class $classname$;\n",
        "classname", *i);
    }

    printer->Print(
      "\n@interface $classname$ : NSObject {\n",
      "classname", classname_);

    printer->Print(
      "}\n");

    // -----------------------------------------------------------------

    // Embed the descriptor.  We simply serialize the entire FileDescriptorProto
    // and embed it as a string literal, which is parsed and built into real
    // descriptors at initialization time.  We unfortunately have to put it in
    // a string literal, not a byte array, because apparently using a literal
    // byte array causes the ObjectiveC compiler to generate *instructions* to
    // initialize each and every byte of the array, e.g. as if you typed:
    //   b[0] = 123; b[1] = 456; b[2] = 789;
    // This makes huge bytecode files and can easily hit the compiler's internal
    // code size limits (error "code to large").  String literals are apparently
    // embedded raw, which is what we want.
    FileDescriptorProto file_proto;
    file_->CopyTo(&file_proto);
    string file_data;
    file_proto.SerializeToString(&file_data);

    printer->Print(
      "+ (PBFileDescriptor*) descriptor;\n"
      "+ (PBFileDescriptor*) buildDescriptor;\n");


    // Static variables.
    //for (int i = 0; i < file_->message_type_count(); i++) {
    //  // TODO(kenton):  Reuse MessageGenerator objects?
    //  MessageGenerator(file_->message_type(i)).GenerateStaticVariablesHeader(printer);
    //}

    // -----------------------------------------------------------------
    printer->Print("@end\n\n");

    for (int i = 0; i < file_->enum_type_count(); i++) {
      EnumGenerator(file_->enum_type(i)).GenerateHeader(printer);
    }
    for (int i = 0; i < file_->service_count(); i++) {
      ServiceGenerator(file_->service(i)).GenerateHeader(printer);
    }
    for (int i = 0; i < file_->message_type_count(); i++) {
      MessageGenerator(file_->message_type(i)).GenerateHeader(printer);
    }
  }

  void DetermineDependenciesWorker(set<string>* dependencies, set<string>* seen_files, const FileDescriptor* file) {
    if (seen_files->find(file->name()) != seen_files->end()) {
      // don't infinitely recurse
      return;
    }

    seen_files->insert(file->name());

    for (int i = 0; i < file->dependency_count(); i++) {
      DetermineDependenciesWorker(dependencies, seen_files, file->dependency(i));
    }

    for (int i = 0; i < file->enum_type_count(); i++) {
      EnumGenerator(file->enum_type(i)).DetermineDependencies(dependencies);
    }
    for (int i = 0; i < file->service_count(); i++) {
      ServiceGenerator(file->service(i)).DetermineDependencies(dependencies);
    }
    for (int i = 0; i < file->message_type_count(); i++) {
      MessageGenerator(file->message_type(i)).DetermineDependencies(dependencies);
    }
  }


  void FileGenerator::DetermineDependencies(set<string>* dependencies) {
    set<string> seen_files;
    DetermineDependenciesWorker(dependencies, &seen_files, file_);
  }

  void FileGenerator::GenerateSource(io::Printer* printer) {
    FileGenerator file_generator(file_);
    string header_file = FileName(file_) + ".pb.h";

    // We don't import anything because we refer to all classes by their
    // fully-qualified names in the generated source.
    printer->Print(
      "// Generated by the protocol buffer compiler.  DO NOT EDIT!\n\n"
      "#import \"$header_file$\"\n\n",
      "header_file", header_file);

    printer->Print(
      "@implementation $classname$\n",
      "classname", classname_);


    // -----------------------------------------------------------------

    // Embed the descriptor.  We simply serialize the entire FileDescriptorProto
    // and embed it as a string literal, which is parsed and built into real
    // descriptors at initialization time.  We unfortunately have to put it in
    // a string literal, not a byte array, because apparently using a literal
    // byte array causes the ObjectiveC compiler to generate *instructions* to
    // initialize each and every byte of the array, e.g. as if you typed:
    //   b[0] = 123; b[1] = 456; b[2] = 789;
    // This makes huge bytecode files and can easily hit the compiler's internal
    // code size limits (error "code to large").  String literals are apparently
    // embedded raw, which is what we want.
    FileDescriptorProto file_proto;
    file_->CopyTo(&file_proto);
    string file_data;
    file_proto.SerializeToString(&file_data);

    printer->Print(
      "static PBFileDescriptor* descriptor = nil;\n");

    for (int i = 0; i < file_->extension_count(); i++) {
      ExtensionGenerator(classname_, file_->extension(i)).GenerateFieldsSource(printer);
    }

    // Static variables.
    for (int i = 0; i < file_->message_type_count(); i++) {
      // TODO(kenton):  Reuse MessageGenerator objects?
      MessageGenerator(file_->message_type(i)).GenerateStaticVariablesSource(printer);
    }

    printer->Print(
      "+ (void) initialize {\n"
      "  if (self == [$classname$ class]) {\n"
      "    descriptor = [[$classname$ buildDescriptor] retain];\n",
      "classname", classname_);

    printer->Indent();
    printer->Indent();

    for (int i = 0; i < file_->extension_count(); i++) {
      ExtensionGenerator(classname_, file_->extension(i)).GenerateInitializationSource(printer);
    }

    // Static variables.
    for (int i = 0; i < file_->message_type_count(); i++) {
      // TODO(kenton):  Reuse MessageGenerator objects?
      MessageGenerator(file_->message_type(i)).GenerateStaticVariablesInitialization(printer);
    }

    printer->Outdent();
    printer->Outdent();

    printer->Print(
      "  }\n"
      "}\n"
      "+ (PBFileDescriptor*) descriptor {\n"
      "  return descriptor;\n"
      "}\n"
      "+ (PBFileDescriptor*) buildDescriptor {\n"
      "  NSString* descriptorData = [NSString stringWithCString:\n",
      "classname", classname_);

    printer->Indent();
    printer->Indent();

    // Only write 40 bytes per line.
    static const int kBytesPerLine = 40;
    for (int i = 0; i < file_data.size(); i += kBytesPerLine) {
      //if (i > 0) printer->Print(" +\n");
      printer->Print("\"$data$\"\n",
        "data", CEscape(file_data.substr(i, kBytesPerLine)));
    }
    printer->Print("];\n");
    printer->Outdent();

    printer->Print(
      "NSArray* dependencies = [NSArray arrayWithObjects:\n");
    for (int i = 0; i < file_->dependency_count(); i++) {
      printer->Print(
        "        [$dependency$ descriptor],\n",
        "dependency", FileClassName(file_->dependency(i)));
    }
    printer->Print(
      "         nil];\n"
      "return [PBFileDescriptor internalBuildGeneratedFileFrom:descriptorData dependencies:dependencies];\n");

    printer->Outdent();

    printer->Print(
      "}\n");

    printer->Print(
      "@end\n\n");

    for (int i = 0; i < file_->enum_type_count(); i++) {
      EnumGenerator(file_->enum_type(i)).GenerateSource(printer);
    }
    for (int i = 0; i < file_->message_type_count(); i++) {
      MessageGenerator(file_->message_type(i)).GenerateSource(printer);
    }
    for (int i = 0; i < file_->service_count(); i++) {
      ServiceGenerator(file_->service(i)).GenerateSource(printer);
    }
  }
}  // namespace objectivec
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
