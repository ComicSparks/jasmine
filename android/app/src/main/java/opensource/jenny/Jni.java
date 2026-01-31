package opensource.jenny;

public class Jni {

    public static native void init(final String path);

    public static native String invoke(final String params);

    static {
        System.loadLibrary("rust");
    }

}
