// Copyright 2009 Google Inc.  All rights reserved.

package com.google.protobuf;

import java.io.FilterInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Collection;

/**
 * A partial implementation of the {@link MessageLite} interface which
 * implements as many methods of that interface as possible in terms of other
 * methods.
 *
 * @author kenton@google.com Kenton Varda
 */
public abstract class AbstractMessageLite implements MessageLite {
  public ByteString toByteString() {
    try {
      final ByteString.CodedBuilder out =
        ByteString.newCodedBuilder(getSerializedSize());
      writeTo(out.getCodedOutput());
      return out.build();
    } catch (IOException e) {
      throw new RuntimeException(
        "Serializing to a ByteString threw an IOException (should " +
        "never happen).", e);
    }
  }

  public byte[] toByteArray() {
    try {
      final byte[] result = new byte[getSerializedSize()];
      final CodedOutputStream output = CodedOutputStream.newInstance(result);
      writeTo(output);
      output.checkNoSpaceLeft();
      return result;
    } catch (IOException e) {
      throw new RuntimeException(
        "Serializing to a byte array threw an IOException " +
        "(should never happen).", e);
    }
  }

  public void writeTo(final OutputStream output) throws IOException {
    final CodedOutputStream codedOutput = CodedOutputStream.newInstance(output);
    writeTo(codedOutput);
    codedOutput.flush();
  }

  public void writeDelimitedTo(final OutputStream output) throws IOException {
    final CodedOutputStream codedOutput = CodedOutputStream.newInstance(output);
    codedOutput.writeRawVarint32(getSerializedSize());
    writeTo(codedOutput);
    codedOutput.flush();
  }

  /**
   * A partial implementation of the {@link Message.Builder} interface which
   * implements as many methods of that interface as possible in terms of
   * other methods.
   */
  @SuppressWarnings("unchecked")
  public static abstract class Builder<BuilderType extends Builder>
      implements MessageLite.Builder {
    // The compiler produces an error if this is not declared explicitly.
    @Override
    public abstract BuilderType clone();

    public BuilderType mergeFrom(final CodedInputStream input)
                                 throws IOException {
      // TODO(kenton):  Don't use null here.  Currently we have to because
      //   using ExtensionRegistry.getEmptyRegistry() would imply a dependency
      //   on ExtensionRegistry.  However, AbstractMessage overrides this with
      //   a correct implementation, and lite messages don't yet support
      //   extensions, so it ends up not mattering for now.  It will matter
      //   once lite messages support extensions.
      return mergeFrom(input, null);
    }

    // Re-defined here for return type covariance.
    public abstract BuilderType mergeFrom(
        final CodedInputStream input,
        final ExtensionRegistryLite extensionRegistry)
        throws IOException;

    public BuilderType mergeFrom(final ByteString data)
        throws InvalidProtocolBufferException {
      try {
        final CodedInputStream input = data.newCodedInput();
        mergeFrom(input);
        input.checkLastTagWas(0);
        return (BuilderType) this;
      } catch (InvalidProtocolBufferException e) {
        throw e;
      } catch (IOException e) {
        throw new RuntimeException(
          "Reading from a ByteString threw an IOException (should " +
          "never happen).", e);
      }
    }

    public BuilderType mergeFrom(
        final ByteString data,
        final ExtensionRegistryLite extensionRegistry)
        throws InvalidProtocolBufferException {
      try {
        final CodedInputStream input = data.newCodedInput();
        mergeFrom(input, extensionRegistry);
        input.checkLastTagWas(0);
        return (BuilderType) this;
      } catch (InvalidProtocolBufferException e) {
        throw e;
      } catch (IOException e) {
        throw new RuntimeException(
          "Reading from a ByteString threw an IOException (should " +
          "never happen).", e);
      }
    }

    public BuilderType mergeFrom(final byte[] data)
        throws InvalidProtocolBufferException {
      return mergeFrom(data, 0, data.length);
    }

    public BuilderType mergeFrom(final byte[] data, final int off,
                                 final int len)
                                 throws InvalidProtocolBufferException {
      try {
        final CodedInputStream input =
            CodedInputStream.newInstance(data, off, len);
        mergeFrom(input);
        input.checkLastTagWas(0);
        return (BuilderType) this;
      } catch (InvalidProtocolBufferException e) {
        throw e;
      } catch (IOException e) {
        throw new RuntimeException(
          "Reading from a byte array threw an IOException (should " +
          "never happen).", e);
      }
    }

    public BuilderType mergeFrom(
        final byte[] data,
        final ExtensionRegistryLite extensionRegistry)
        throws InvalidProtocolBufferException {
      return mergeFrom(data, 0, data.length, extensionRegistry);
    }

    public BuilderType mergeFrom(
        final byte[] data, final int off, final int len,
        final ExtensionRegistryLite extensionRegistry)
        throws InvalidProtocolBufferException {
      try {
        final CodedInputStream input =
            CodedInputStream.newInstance(data, off, len);
        mergeFrom(input, extensionRegistry);
        input.checkLastTagWas(0);
        return (BuilderType) this;
      } catch (InvalidProtocolBufferException e) {
        throw e;
      } catch (IOException e) {
        throw new RuntimeException(
          "Reading from a byte array threw an IOException (should " +
          "never happen).", e);
      }
    }

    public BuilderType mergeFrom(final InputStream input) throws IOException {
      final CodedInputStream codedInput = CodedInputStream.newInstance(input);
      mergeFrom(codedInput);
      codedInput.checkLastTagWas(0);
      return (BuilderType) this;
    }

    public BuilderType mergeFrom(
        final InputStream input,
        final ExtensionRegistryLite extensionRegistry)
        throws IOException {
      final CodedInputStream codedInput = CodedInputStream.newInstance(input);
      mergeFrom(codedInput, extensionRegistry);
      codedInput.checkLastTagWas(0);
      return (BuilderType) this;
    }

    /**
     * An InputStream implementations which reads from some other InputStream
     * but is limited to a particular number of bytes.  Used by
     * mergeDelimitedFrom().  This is intentionally package-private so that
     * UnknownFieldSet can share it.
     */
    static final class LimitedInputStream extends FilterInputStream {
      private int limit;

      LimitedInputStream(InputStream in, int limit) {
        super(in);
        this.limit = limit;
      }

      @Override
      public int available() throws IOException {
        return Math.min(super.available(), limit);
      }

      @Override
      public int read() throws IOException {
        if (limit <= 0) {
          return -1;
        }
        final int result = super.read();
        if (result >= 0) {
          --limit;
        }
        return result;
      }

      @Override
      public int read(final byte[] b, final int off, int len)
                      throws IOException {
        if (limit <= 0) {
          return -1;
        }
        len = Math.min(len, limit);
        final int result = super.read(b, off, len);
        if (result >= 0) {
          limit -= result;
        }
        return result;
      }

      @Override
      public long skip(final long n) throws IOException {
        final long result = super.skip(Math.min(n, limit));
        if (result >= 0) {
          limit -= result;
        }
        return result;
      }
    }

    public BuilderType mergeDelimitedFrom(
        final InputStream input,
        final ExtensionRegistryLite extensionRegistry)
        throws IOException {
      final int size = CodedInputStream.readRawVarint32(input);
      final InputStream limitedInput = new LimitedInputStream(input, size);
      return mergeFrom(limitedInput, extensionRegistry);
    }

    public BuilderType mergeDelimitedFrom(final InputStream input)
        throws IOException {
      final int size = CodedInputStream.readRawVarint32(input);
      final InputStream limitedInput = new LimitedInputStream(input, size);
      return mergeFrom(limitedInput);
    }

    /**
     * Construct an UninitializedMessageException reporting missing fields in
     * the given message.
     */
    protected static UninitializedMessageException
        newUninitializedMessageException(MessageLite message) {
      return new UninitializedMessageException(message);
    }

    /**
     * Adds the {@code values} to the {@code list}.  This is a helper method
     * used by generated code.  Users should ignore it.
     *
     * @throws NullPointerException if any of the elements of {@code values} is
     * null.
     */
    protected static <T> void addAll(final Iterable<T> values,
                                     final Collection<? super T> list) {
      for (final T value : values) {
        if (value == null) {
          throw new NullPointerException();
        }
      }
      if (values instanceof Collection) {
        final Collection<T> collection = (Collection<T>) values;
        list.addAll(collection);
      } else {
        for (final T value : values) {
          list.add(value);
        }
      }
    }
  }
}