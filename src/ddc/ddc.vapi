[CCode(cheader_filename = "ddc.h")]
namespace DDC {
    [CCode(cname = "initDDC")]
    public int init();

    [CCode(cname = "closeDDC")]
    public void close();

    [CCode(cname = "getBrightness")]
    public int get_brightness();

    [CCode(cname = "setBrightness")]
    public void set_brightness(int brightness);
}
