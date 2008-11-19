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

package com.google.protobuf;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.*;

/**
 * {@code UnknownFieldSet} is used to keep track of fields which were seen when parsing a protocol message but whose
 * field numbers or types are unrecognized. This most frequently occurs when new fields are added to a message type and
 * then messages containing those feilds are read by old software that was compiled before the new types were added.
 * <p/>
 * <p>Every {@link Message} contains an {@code UnknownFieldSet} (and every {@link Message.Builder} contains an {@link
 * UnknownFieldSet.Builder}).
 * <p/>
 * <p>Most users will never need to use this class.
 *
 * @author kenton@google.com Kenton Varda
 */
public final class UnknownFieldSet {
  private UnknownFieldSet() {}

  /** Create a new {@link UnknownFieldSet.Builder}. */
  public static Builder newBuilder() {
    return new Builder();
  }

  /** Create a new {@link UnknownFieldSet.Builder} and initialize it to be a copy of {@code copyFrom}. */
  public static Builder newBuilder(final UnknownFieldSet copyFrom) {
    return new Builder().mergeFrom(copyFrom);
  }

  /** Get an empty {@code UnknownFieldSet}. */
  public static UnknownFieldSet getDefaultInstance() {
    return defaultInstance;
  }

  private static UnknownFieldSet defaultInstance = new UnknownFieldSet(Collections.<Integer, Field>emptyMap());

  /** Construct an {@code UnknownFieldSet} around the given map.  The map is expected to be immutable. */
  private UnknownFieldSet(final Map<Integer, Field> fields) {
    this.fields = fields;
  }

  private Map<Integer, Field> fields;

  /** Get a map of fields in the set by number. */
  public Map<Integer, Field> asMap() {
    return this.fields;
  }

  /** Check if the given field number is present in the set. */
  public boolean hasField(final int number) {
    return this.fields.containsKey(number);
  }

  /** Get a field by number.  Returns an empty field if not present.  Never returns {@code null}. */
  public Field getField(final int number) {
    final Field result = this.fields.get(number);
    return result == null ? Field.getDefaultInstance() : result;
  }

  /** Serializes the set and writes it to {@code output}. */
  public void writeTo(final CodedOutputStream output) throws IOException {
    for (final Map.Entry<Integer, Field> entry : this.fields.entrySet()) {
      entry.getValue().writeTo(entry.getKey(), output);
    }
  }

  /**
   * Converts the set to a string in protocol buffer text format. This is just a trivial wrapper around {@link
   * TextFormat#printToString(UnknownFieldSet)}.
   */
  public final String toString() {
    return TextFormat.printToString(this);
  }

  /**
   * Serializes the message to a {@code ByteString} and returns it. This is just a trivial wrapper around {@link
   * #writeTo(CodedOutputStream)}.
   */
  public final ByteString toByteString() {
    try {
      final ByteString.CodedBuilder out = ByteString.newCodedBuilder(getSerializedSize());
      writeTo(out.getCodedOutput());
      return out.build();
    } catch (final IOException e) {
      throw new RuntimeException("Serializing to a ByteString threw an IOException (should " + "never happen).", e);
    }
  }

  /**
   * Serializes the message to a {@code byte} array and returns it.  This is just a trivial wrapper around {@link
   * #writeTo(CodedOutputStream)}.
   */
  public final byte[] toByteArray() {
    try {
      final byte[] result = new byte[getSerializedSize()];
      final CodedOutputStream output = CodedOutputStream.newInstance(result);
      writeTo(output);
      output.checkNoSpaceLeft();
      return result;
    } catch (final IOException e) {
      throw new RuntimeException("Serializing to a byte array threw an IOException " + "(should never happen).", e);
    }
  }

  /**
   * Serializes the message and writes it to {@code output}.  This is just a trivial wrapper around {@link
   * #writeTo(CodedOutputStream)}.
   */
  public final void writeTo(final OutputStream output) throws IOException {
    final CodedOutputStream codedOutput = CodedOutputStream.newInstance(output);
    writeTo(codedOutput);
    codedOutput.flush();
  }

  /** Get the number of bytes required to encode this set. */
  public int getSerializedSize() {
    int result = 0;
    for (final Map.Entry<Integer, Field> entry : this.fields.entrySet()) {
      result += entry.getValue().getSerializedSize(entry.getKey());
    }
    return result;
  }

  /** Serializes the set and writes it to {@code output} using {@code MessageSet} wire format. */
  public void writeAsMessageSetTo(final CodedOutputStream output) throws IOException {
    for (final Map.Entry<Integer, Field> entry : this.fields.entrySet()) {
      entry.getValue().writeAsMessageSetExtensionTo(entry.getKey(), output);
    }
  }

  /** Get the number of bytes required to encode this set using {@code MessageSet} wire format. */
  public int getSerializedSizeAsMessageSet() {
    int result = 0;
    for (final Map.Entry<Integer, Field> entry : this.fields.entrySet()) {
      result += entry.getValue().getSerializedSizeAsMessageSetExtension(entry.getKey());
    }
    return result;
  }

  /** Parse an {@code UnknownFieldSet} from the given input stream. */
  static public UnknownFieldSet parseFrom(final CodedInputStream input) throws IOException {
    return newBuilder().mergeFrom(input).build();
  }

  /** Parse {@code data} as an {@code UnknownFieldSet} and return it. */
  public static UnknownFieldSet parseFrom(final ByteString data) throws InvalidProtocolBufferException {
    return newBuilder().mergeFrom(data).build();
  }

  /** Parse {@code data} as an {@code UnknownFieldSet} and return it. */
  public static UnknownFieldSet parseFrom(final byte[] data) throws InvalidProtocolBufferException {
    return newBuilder().mergeFrom(data).build();
  }

  /** Parse an {@code UnknownFieldSet} from {@code input} and return it. */
  public static UnknownFieldSet parseFrom(final InputStream input) throws IOException {
    return newBuilder().mergeFrom(input).build();
  }

  /**
   * Builder for {@link UnknownFieldSet}s.
   * <p/>
   * <p>Note that this class maintains {@link Field.Builder}s for all fields in the set.  Thus, adding one element to an
   * existing {@link Field} does not require making a copy.  This is important for efficient parsing of unknown repeated
   * fields.  However, it implies that {@link Field}s cannot be constructed independently, nor can two {@link
   * UnknownFieldSet}s share the same {@code Field} object.
   * <p/>
   * <p>Use {@link UnknownFieldSet#newBuilder()} to construct a {@code Builder}.
   */
  public static final class Builder {
    private Builder() {}

    private Map<Integer, Field> fields = new TreeMap<Integer, Field>();

    // Optimization:  We keep around a builder for the last field that was
    //   modified so that we can efficiently add to it multiple times in a
    //   row (important when parsing an unknown repeated field).
    int lastFieldNumber = 0;
    Field.Builder lastField = null;

    /** Get a field builder for the given field number which includes any values that already exist. */
    private Field.Builder getFieldBuilder(final int number) {
      if (this.lastField != null) {
        if (number == this.lastFieldNumber) {
          return this.lastField;
        }
        // Note:  addField() will reset lastField and lastFieldNumber.
        addField(this.lastFieldNumber, this.lastField.build());
      }
      if (number == 0) {
        return null;
      } else {
        final Field existing = this.fields.get(number);
        this.lastFieldNumber = number;
        this.lastField = Field.newBuilder();
        if (existing != null) {
          this.lastField.mergeFrom(existing);
        }
        return this.lastField;
      }
    }

    /**
     * Build the {@link UnknownFieldSet} and return it.
     * <p/>
     * <p>Once {@code build()} has been called, the {@code Builder} will no longer be usable.  Calling any method after
     * {@code build()} will throw {@code NullPointerException}.
     */
    public UnknownFieldSet build() {
      getFieldBuilder(0);  // Force lastField to be built.
      UnknownFieldSet result;
      if (this.fields.isEmpty()) {
        result = getDefaultInstance();
      } else {
        result = new UnknownFieldSet(Collections.unmodifiableMap(this.fields));
      }
      this.fields = null;
      return result;
    }

    /** Reset the builder to an empty set. */
    public Builder clear() {
      this.fields = new TreeMap<Integer, Field>();
      this.lastFieldNumber = 0;
      this.lastField = null;
      return this;
    }

    /**
     * Merge the fields from {@code other} into this set.  If a field number exists in both sets, {@code other}'s values
     * for that field will be appended to the values in this set.
     */
    public Builder mergeFrom(final UnknownFieldSet other) {
      if (other != getDefaultInstance()) {
        for (final Map.Entry<Integer, Field> entry : other.fields.entrySet()) {
          mergeField(entry.getKey(), entry.getValue());
        }
      }
      return this;
    }

    /** Add a field to the {@code UnknownFieldSet}.  If a field with the same number already exists, the two are merged. */
    public Builder mergeField(final int number, final Field field) {
      if (number == 0) {
        throw new IllegalArgumentException("Zero is not a valid field number.");
      }
      if (hasField(number)) {
        getFieldBuilder(number).mergeFrom(field);
      } else {
        // Optimization:  We could call getFieldBuilder(number).mergeFrom(field)
        // in this case, but that would create a copy of the Field object.
        // We'd rather reuse the one passed to us, so call addField() instead.
        addField(number, field);
      }
      return this;
    }

    /**
     * Convenience method for merging a new field containing a single varint value.  This is used in particular when an
     * unknown enum value is encountered.
     */
    public Builder mergeVarintField(final int number, final int value) {
      if (number == 0) {
        throw new IllegalArgumentException("Zero is not a valid field number.");
      }
      getFieldBuilder(number).addVarint(value);
      return this;
    }

    /** Check if the given field number is present in the set. */
    public boolean hasField(final int number) {
      if (number == 0) {
        throw new IllegalArgumentException("Zero is not a valid field number.");
      }
      return number == this.lastFieldNumber || this.fields.containsKey(number);
    }

    /** Add a field to the {@code UnknownFieldSet}.  If a field with the same number already exists, it is removed. */
    public Builder addField(final int number, final Field field) {
      if (number == 0) {
        throw new IllegalArgumentException("Zero is not a valid field number.");
      }
      if (this.lastField != null && this.lastFieldNumber == number) {
        // Discard this.
        this.lastField = null;
        this.lastFieldNumber = 0;
      }
      this.fields.put(number, field);
      return this;
    }

    /**
     * Get all present {@code Field}s as an immutable {@code Map}.  If more fields are added, the changes may or may not
     * be reflected in this map.
     */
    public Map<Integer, Field> asMap() {
      getFieldBuilder(0);  // Force lastField to be built.
      return Collections.unmodifiableMap(this.fields);
    }

    /** Parse an entire message from {@code input} and merge its fields into this set. */
    public Builder mergeFrom(final CodedInputStream input) throws IOException {
      while (true) {
        final int tag = input.readTag();
        if (tag == 0 || !mergeFieldFrom(tag, input)) {
          break;
        }
      }
      return this;
    }

    /**
     * Parse a single field from {@code input} and merge it into this set.
     *
     * @param tag The field's tag number, which was already parsed.
     *
     * @return {@code false} if the tag is an engroup tag.
     */
    public boolean mergeFieldFrom(final int tag, final CodedInputStream input) throws IOException {
      final int number = WireFormat.getTagFieldNumber(tag);
      switch (WireFormat.getTagWireType(tag)) {
        case WireFormat.WIRETYPE_VARINT:
          getFieldBuilder(number).addVarint(input.readInt64());
          return true;
        case WireFormat.WIRETYPE_FIXED64:
          getFieldBuilder(number).addFixed64(input.readFixed64());
          return true;
        case WireFormat.WIRETYPE_LENGTH_DELIMITED:
          getFieldBuilder(number).addLengthDelimited(input.readBytes());
          return true;
        case WireFormat.WIRETYPE_START_GROUP: {
          final UnknownFieldSet.Builder subBuilder = UnknownFieldSet.newBuilder();
          input.readUnknownGroup(number, subBuilder);
          getFieldBuilder(number).addGroup(subBuilder.build());
          return true;
        }
        case WireFormat.WIRETYPE_END_GROUP:
          return false;
        case WireFormat.WIRETYPE_FIXED32:
          getFieldBuilder(number).addFixed32(input.readFixed32());
          return true;
        default:
          throw InvalidProtocolBufferException.invalidWireType();
      }
    }

    /**
     * Parse {@code data} as an {@code UnknownFieldSet} and merge it with the set being built.  This is just a small
     * wrapper around {@link #mergeFrom(CodedInputStream)}.
     */
    public Builder mergeFrom(final ByteString data) throws InvalidProtocolBufferException {
      try {
        final CodedInputStream input = data.newCodedInput();
        mergeFrom(input);
        input.checkLastTagWas(0);
        return this;
      } catch (final InvalidProtocolBufferException e) {
        throw e;
      } catch (final IOException e) {
        throw new RuntimeException("Reading from a ByteString threw an IOException (should " + "never happen).", e);
      }
    }

    /**
     * Parse {@code data} as an {@code UnknownFieldSet} and merge it with the set being built.  This is just a small
     * wrapper around {@link #mergeFrom(CodedInputStream)}.
     */
    public Builder mergeFrom(final byte[] data) throws InvalidProtocolBufferException {
      try {
        final CodedInputStream input = CodedInputStream.newInstance(data);
        mergeFrom(input);
        input.checkLastTagWas(0);
        return this;
      } catch (final InvalidProtocolBufferException e) {
        throw e;
      } catch (final IOException e) {
        throw new RuntimeException("Reading from a byte array threw an IOException (should " + "never happen).", e);
      }
    }

    /**
     * Parse an {@code UnknownFieldSet} from {@code input} and merge it with the set being built.  This is just a small
     * wrapper around {@link #mergeFrom(CodedInputStream)}.
     */
    public Builder mergeFrom(final InputStream input) throws IOException {
      final CodedInputStream codedInput = CodedInputStream.newInstance(input);
      mergeFrom(codedInput);
      codedInput.checkLastTagWas(0);
      return this;
    }
  }

  /**
   * Represents a single field in an {@code UnknownFieldSet}.
   * <p/>
   * <p>A {@code Field} consists of five lists of values.  The lists correspond to the five "wire types" used in the
   * protocol buffer binary format. The wire type of each field can be determined from the encoded form alone, without
   * knowing the field's declared type.  So, we are able to parse unknown values at least this far and separate them.
   * Normally, only one of the five lists will contain any values, since it is impossible to define a valid message type
   * that declares two different types for the same field number.  However, the code is designed to allow for the case
   * where the same unknown field number is encountered using multiple different wire types.
   * <p/>
   * <p>{@code Field} is an immutable class.  To construct one, you must use a {@link Field.Builder}.
   *
   * @see UnknownFieldSet
   */
  public static final class Field {
    private Field() {}

    /** Construct a new {@link Builder}. */
    public static Builder newBuilder() {
      return new Builder();
    }

    /** Construct a new {@link Builder} and initialize it to a copy of {@code copyFrom}. */
    public static Builder newBuilder(final Field copyFrom) {
      return new Builder().mergeFrom(copyFrom);
    }

    /** Get an empty {@code Field}. */
    public static Field getDefaultInstance() {
      return defaultInstance;
    }

    private static Field defaultInstance = newBuilder().build();

    /** Get the list of varint values for this field. */
    public List<Long> getVarintList() { return this.varint; }

    /** Get the list of fixed32 values for this field. */
    public List<Integer> getFixed32List() { return this.fixed32; }

    /** Get the list of fixed64 values for this field. */
    public List<Long> getFixed64List() { return this.fixed64; }

    /** Get the list of length-delimited values for this field. */
    public List<ByteString> getLengthDelimitedList() { return this.lengthDelimited; }

    /**
     * Get the list of embedded group values for this field.  These are represented using {@link UnknownFieldSet}s
     * rather than {@link Message}s since the group's type is presumably unknown.
     */
    public List<UnknownFieldSet> getGroupList() { return this.group; }

    /** Serializes the field, including field number, and writes it to {@code output}. */
    public void writeTo(final int fieldNumber, final CodedOutputStream output) throws IOException {
      for (final long value : this.varint) {
        output.writeUInt64(fieldNumber, value);
      }
      for (final int value : this.fixed32) {
        output.writeFixed32(fieldNumber, value);
      }
      for (final long value : this.fixed64) {
        output.writeFixed64(fieldNumber, value);
      }
      for (final ByteString value : this.lengthDelimited) {
        output.writeBytes(fieldNumber, value);
      }
      for (final UnknownFieldSet value : this.group) {
        output.writeUnknownGroup(fieldNumber, value);
      }
    }

    /** Get the number of bytes required to encode this field, including field number. */
    public int getSerializedSize(final int fieldNumber) {
      int result = 0;
      for (final long value : this.varint) {
        result += CodedOutputStream.computeUInt64Size(fieldNumber, value);
      }
      for (final int value : this.fixed32) {
        result += CodedOutputStream.computeFixed32Size(fieldNumber, value);
      }
      for (final long value : this.fixed64) {
        result += CodedOutputStream.computeFixed64Size(fieldNumber, value);
      }
      for (final ByteString value : this.lengthDelimited) {
        result += CodedOutputStream.computeBytesSize(fieldNumber, value);
      }
      for (final UnknownFieldSet value : this.group) {
        result += CodedOutputStream.computeUnknownGroupSize(fieldNumber, value);
      }
      return result;
    }

    /**
     * Serializes the field, including field number, and writes it to {@code output}, using {@code MessageSet} wire
     * format.
     */
    public void writeAsMessageSetExtensionTo(final int fieldNumber, final CodedOutputStream output) throws IOException {
      for (final ByteString value : this.lengthDelimited) {
        output.writeRawMessageSetExtension(fieldNumber, value);
      }
    }

    /**
     * Get the number of bytes required to encode this field, including field number, using {@code MessageSet} wire
     * format.
     */
    public int getSerializedSizeAsMessageSetExtension(final int fieldNumber) {
      int result = 0;
      for (final ByteString value : this.lengthDelimited) {
        result += CodedOutputStream.computeRawMessageSetExtensionSize(fieldNumber, value);
      }
      return result;
    }

    private List<Long> varint;
    private List<Integer> fixed32;
    private List<Long> fixed64;
    private List<ByteString> lengthDelimited;
    private List<UnknownFieldSet> group;

    /**
     * Used to build a {@link Field} within an {@link UnknownFieldSet}.
     * <p/>
     * <p>Use {@link Field#newBuilder()} to construct a {@code Builder}.
     */
    public static final class Builder {
      private Builder() {}

      private Field result = new Field();

      /**
       * Build the field.  After {@code build()} has been called, the {@code Builder} is no longer usable.  Calling any
       * other method will throw a {@code NullPointerException}.
       */
      public Field build() {
        if (this.result.varint == null) {
          this.result.varint = Collections.emptyList();
        } else {
          this.result.varint = Collections.unmodifiableList(this.result.varint);
        }
        if (this.result.fixed32 == null) {
          this.result.fixed32 = Collections.emptyList();
        } else {
          this.result.fixed32 = Collections.unmodifiableList(this.result.fixed32);
        }
        if (this.result.fixed64 == null) {
          this.result.fixed64 = Collections.emptyList();
        } else {
          this.result.fixed64 = Collections.unmodifiableList(this.result.fixed64);
        }
        if (this.result.lengthDelimited == null) {
          this.result.lengthDelimited = Collections.emptyList();
        } else {
          this.result.lengthDelimited = Collections.unmodifiableList(this.result.lengthDelimited);
        }
        if (this.result.group == null) {
          this.result.group = Collections.emptyList();
        } else {
          this.result.group = Collections.unmodifiableList(this.result.group);
        }

        final Field returnMe = this.result;
        this.result = null;
        return returnMe;
      }

      /** Discard the field's contents. */
      public Builder clear() {
        this.result = new Field();
        return this;
      }

      /**
       * Merge the values in {@code other} into this field.  For each list of values, {@code other}'s values are append
       * to the ones in this field.
       */
      public Builder mergeFrom(final Field other) {
        if (!other.varint.isEmpty()) {
          if (this.result.varint == null) {
            this.result.varint = new ArrayList<Long>();
          }
          this.result.varint.addAll(other.varint);
        }
        if (!other.fixed32.isEmpty()) {
          if (this.result.fixed32 == null) {
            this.result.fixed32 = new ArrayList<Integer>();
          }
          this.result.fixed32.addAll(other.fixed32);
        }
        if (!other.fixed64.isEmpty()) {
          if (this.result.fixed64 == null) {
            this.result.fixed64 = new ArrayList<Long>();
          }
          this.result.fixed64.addAll(other.fixed64);
        }
        if (!other.lengthDelimited.isEmpty()) {
          if (this.result.lengthDelimited == null) {
            this.result.lengthDelimited = new ArrayList<ByteString>();
          }
          this.result.lengthDelimited.addAll(other.lengthDelimited);
        }
        if (!other.group.isEmpty()) {
          if (this.result.group == null) {
            this.result.group = new ArrayList<UnknownFieldSet>();
          }
          this.result.group.addAll(other.group);
        }
        return this;
      }

      /** Add a varint value. */
      public Builder addVarint(final long value) {
        if (this.result.varint == null) {
          this.result.varint = new ArrayList<Long>();
        }
        this.result.varint.add(value);
        return this;
      }

      /** Add a fixed32 value. */
      public Builder addFixed32(final int value) {
        if (this.result.fixed32 == null) {
          this.result.fixed32 = new ArrayList<Integer>();
        }
        this.result.fixed32.add(value);
        return this;
      }

      /** Add a fixed64 value. */
      public Builder addFixed64(final long value) {
        if (this.result.fixed64 == null) {
          this.result.fixed64 = new ArrayList<Long>();
        }
        this.result.fixed64.add(value);
        return this;
      }

      /** Add a length-delimited value. */
      public Builder addLengthDelimited(final ByteString value) {
        if (this.result.lengthDelimited == null) {
          this.result.lengthDelimited = new ArrayList<ByteString>();
        }
        this.result.lengthDelimited.add(value);
        return this;
      }

      /** Add an embedded group. */
      public Builder addGroup(final UnknownFieldSet value) {
        if (this.result.group == null) {
          this.result.group = new ArrayList<UnknownFieldSet>();
        }
        this.result.group.add(value);
        return this;
      }
    }
  }
}
