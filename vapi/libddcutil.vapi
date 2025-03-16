[CCode (cheader_filename = "ddcutil_c_api.h,ddcutil_macros.h,ddcutil_status_codes.h,ddcutil_types.h")]
namespace DDCUtil {

    [CCode (cname = "DDCA_Ddcutil_Version_Spec")]
    public struct DdcutilVersionSpec {
        public uint8 major;
        public uint8 minor;
        public uint8 micro;
    }

    [CCode (cname = "DDCA_Error_Detail")]
    public struct ErrorDetail {
        public string marker;
        public int status_code;
        public string detail;
        public uint16 cause_ct;
        public ErrorDetail[] causes;
    }

    [CCode (cname = "DDCA_Status", cprefix = "DDCRC_")]
    public enum Status {
        OK = 0,
        DDC_DATA = -3001,
        NULL_RESPONSE = -3002,
        MULTI_PART_READ_FRAGMENT = -3003,
        ALL_TRIES_ZERO = -3004,
        REPORTED_UNSUPPORTED = -3005,
        READ_ALL_ZERO = -3006,
        RETRIES = -3007,
        EDID = -3008,
        READ_EDID = -3009,
        INVALID_EDID = -3010,
        ALL_RESPONSES_NULL = -3011,
        DETERMINED_UNSUPPORTED = -3012,
        ARG = -3013,
        INVALID_OPERATION = -3014,
        UNIMPLEMENTED = -3015,
        UNINITIALIZED = -3016,
        UNKNOWN_FEATURE = -3017,
        INTERPRETATION_FAILED = -3018,
        MULTI_FEATURE_ERROR = -3019,
        INVALID_DISPLAY = -3020,
        INTERNAL_ERROR = -3021,
        OTHER = -3022,
        VERIFY = -3023,
        NOT_FOUND = -3024,
        LOCKED = -3025,
        ALREADY_OPEN = -3026,
        BAD_DATA = -3027
    }

    [CCode (cname = "DDCA_Display_Ref")]
    public struct DisplayRef {
        // Opaque struct
    }

    [CCode (cname = "DDCA_Display_Handle")]
    public struct DisplayHandle {
        // Opaque struct
    }

    [CCode (cname = "DDCA_Display_Identifier")]
    public struct DisplayIdentifier {
        // Opaque struct
    }

    [CCode (cname = "DDCA_Display_Info")]
    public struct DisplayInfo {
        public string marker;
        public int dispno;
        public IOPath path;
        public int usb_bus;
        public int usb_device;
        public string mfg_id;
        public string model_name;
        public string sn;
        public uint16 product_code;
        public uint8[] edid_bytes;
        public MCCSVersionSpec vcp_version;
        public DisplayRef dref;
    }

    [CCode (cname = "DDCA_IO_Path")]
    public struct IOPath {
        public IOMode io_mode;
        [CCode (cname = "DDCA_IO_Path.path.i2c_busno")]
        public int i2c_busno;
        [CCode (cname = "DDCA_IO_Path.path.adlno")]
        public Adlno adlno;
        [CCode (cname = "DDCA_IO_Path.path.hiddev_devno")]
        public int hiddev_devno;
    }

    [CCode (cname = "DDCA_IO_Mode")]
    public enum IOMode {
        I2C,
        ADL,
        USB
    }

    [CCode (cname = "DDCA_Adlno")]
    public struct Adlno {
        public int iAdapterIndex;
        public int iDisplayIndex;
    }

    [CCode (cname = "DDCA_MCCS_Version_Spec")]
    public struct MCCSVersionSpec {
        public uint8 major;
        public uint8 minor;
    }

    [CCode (cname = "DDCA_Output_Level")]
    public enum OutputLevel {
        TERSE = 0x04,
        NORMAL = 0x08,
        VERBOSE = 0x10,
        VV = 0x20
    }

    [CCode (cname = "DDCA_Trace_Group")]
    public enum TraceGroup {
        BASE = 0x0080,
        I2C = 0x0040,
        ADL = 0x0020,
        DDC = 0x0010,
        USB = 0x0008,
        TOP = 0x0004,
        ENV = 0x0002,
        API = 0x0001,
        UDF = 0x0100,
        VCP = 0x0200,
        DDCIO = 0x0400,
        SLEEP = 0x0800,
        RETRY = 0x1000,
        NONE = 0x0000,
        ALL = 0xffff
    }

    [CCode (cname = "DDCA_Trace_Options")]
    public enum TraceOptions {
        TIMESTAMP = 0x01,
        THREAD_ID = 0x02,
        WALLTIME = 0x04
    }

    [CCode (cname = "DDCA_Stats_Type")]
    public enum StatsType {
        NONE = 0x00,
        TRIES = 0x01,
        ERRORS = 0x02,
        CALLS = 0x04,
        ELAPSED = 0x08,
        ALL = 0xFF
    }

    [CCode (cname = "DDCA_Capture_Option_Flags")]
    public enum CaptureOptionFlags {
        NOOPTS = 0,
        STDERR = 1
    }

    [CCode (cname = "DDCA_Build_Option_Flags")]
    public enum BuildOptionFlags {
        BUILT_WITH_ADL = 0x01,
        BUILT_WITH_USB = 0x02,
        BUILT_WITH_FAILSIM = 0x04
    }

    //  [CCode (cname = "DDCA_Vcp_Feature_Code")]
    //  public struct VcpFeatureCode {
    //      public uint8 code;
    //  }

    [SimpleType]
    [CCode (cname = "DDCA_Vcp_Feature_Code", has_type_id = false)]
    public struct VcpFeatureCode : uint8 {
    }

    [CCode (cname = "DDCA_Non_Table_Vcp_Value")]
    public struct NonTableVcpValue {
        public uint8 mh;
        public uint8 ml;
        public uint8 sh;
        public uint8 sl;
    }

    [CCode (cname = "DDCA_Table_Vcp_Value")]
    public struct TableVcpValue {
        public uint16 bytect;
        public uint8[] bytes;
    }

    [CCode (cname = "DDCA_Any_Vcp_Value")]
    public struct AnyVcpValue {
        public VcpFeatureCode opcode;
        public VcpValueType value_type;
        [CCode (cname = "DDCA_Any_Vcp_Value.val.t")]
        public TableVcpValue t;
        [CCode (cname = "DDCA_Any_Vcp_Value.val.c_nc")]
        public NonTableVcpValue c_nc;
    }

    [CCode (cname = "DDCA_Vcp_Value_Type")]
    public enum VcpValueType {
        NON_TABLE_VCP_VALUE = 1,
        TABLE_VCP_VALUE = 2
    }

    // Function declarations
    [CCode (cname = "ddca_ddcutil_version")]
    public static DdcutilVersionSpec ddcutil_version();

    [CCode (cname = "ddca_ddcutil_version_string")]
    public static string ddcutil_version_string();

    [CCode (cname = "ddca_ddcutil_extended_version_string")]
    public static string ddcutil_extended_version_string();

    [CCode (cname = "ddca_build_options")]
    public static BuildOptionFlags build_options();

    [CCode (cname = "ddca_get_error_detail")]
    public static ErrorDetail get_error_detail();

    [CCode (cname = "ddca_free_error_detail")]
    public static void free_error_detail(ErrorDetail ddca_erec);

    [CCode (cname = "ddca_report_error_detail")]
    public static void report_error_detail(ErrorDetail ddca_erec, int depth);

    [CCode (cname = "ddca_rc_name")]
    public static string rc_name(Status status_code);

    [CCode (cname = "ddca_rc_desc")]
    public static string rc_desc(Status status_code);

    [CCode (cname = "DDCA_Retry_Type")]
    public enum RetryType {
        WRITE_ONLY_TRIES,
        WRITE_READ_TRIES,
        MULTI_PART_TRIES
    }

    [CCode (cname = "ddca_max_max_tries")]
    public static int max_max_tries();

    [CCode (cname = "ddca_get_max_tries")]
    public static int get_max_tries(RetryType retry_type);

    [CCode (cname = "ddca_set_max_tries")]
    public static Status set_max_tries(RetryType retry_type, int max_tries);

    [CCode (cname = "ddca_enable_verify")]
    public static bool enable_verify(bool onoff);

    [CCode (cname = "ddca_is_verify_enabled")]
    public static bool is_verify_enabled();

    [CCode (cname = "ddca_enable_force_slave_address")]
    public static bool enable_force_slave_address(bool onoff);

    [CCode (cname = "ddca_is_force_slave_address_enabled")]
    public static bool is_force_slave_address_enabled();

    [CCode (cname = "ddca_set_default_sleep_multiplier")]
    public static double set_default_sleep_multiplier(double multiplier);

    [CCode (cname = "ddca_get_default_sleep_multiplier")]
    public static double get_default_sleep_multiplier();

    [CCode (cname = "ddca_set_sleep_multiplier")]
    public static double set_sleep_multiplier(double multiplier);

    [CCode (cname = "ddca_get_sleep_multiplier")]
    public static double get_sleep_multiplier();

    [CCode (cname = "ddca_set_fout")]
    public static void set_fout(GLib.FileStream fout);

    [CCode (cname = "ddca_set_fout_to_default")]
    public static void set_fout_to_default();

    [CCode (cname = "ddca_set_ferr")]
    public static void set_ferr(GLib.FileStream ferr);

    [CCode (cname = "ddca_set_ferr_to_default")]
    public static void set_ferr_to_default();

    [CCode (cname = "ddca_start_capture")]
    public static void start_capture(CaptureOptionFlags flags);

    [CCode (cname = "ddca_end_capture")]
    public static string end_capture();

    [CCode (cname = "ddca_get_output_level")]
    public static OutputLevel get_output_level();

    [CCode (cname = "ddca_set_output_level")]
    public static OutputLevel set_output_level(OutputLevel newval);

    [CCode (cname = "ddca_output_level_name")]
    public static string output_level_name(OutputLevel val);

    [CCode (cname = "ddca_enable_report_ddc_errors")]
    public static bool enable_report_ddc_errors(bool onoff);

    [CCode (cname = "ddca_is_report_ddc_errors_enabled")]
    public static bool is_report_ddc_errors_enabled();

    [CCode (cname = "ddca_add_traced_function")]
    public static void add_traced_function(string funcname);

    [CCode (cname = "ddca_add_traced_file")]
    public static void add_traced_file(string filename);

    [CCode (cname = "ddca_set_trace_groups")]
    public static void set_trace_groups(TraceGroup trace_flags);

    [CCode (cname = "ddca_add_trace_groups")]
    public static void add_trace_groups(TraceGroup trace_flags);

    [CCode (cname = "ddca_trace_group_name_to_value")]
    public static TraceGroup trace_group_name_to_value(string name);

    [CCode (cname = "ddca_set_trace_options")]
    public static void set_trace_options(TraceOptions options);

    [CCode (cname = "ddca_reset_stats")]
    public static void reset_stats();

    [CCode (cname = "ddca_set_thread_description")]
    public static void set_thread_description(string description);

    [CCode (cname = "ddca_append_thread_description")]
    public static void append_thread_description(string description);

    [CCode (cname = "ddca_get_thread_descripton")]
    public static string get_thread_descripton();

    [CCode (cname = "ddca_show_stats")]
    public static void show_stats(StatsType stats, bool include_per_thread_data, int depth);

    [CCode (cname = "ddca_enable_error_info")]
    public static bool enable_error_info(bool enable);

    [CCode (cname = "ddca_enable_usb_display_detection")]
    public static Status enable_usb_display_detection(bool onoff);

    [CCode (cname = "ddca_ddca_is_usb_display_detection_enabled")]
    public static bool is_usb_display_detection_enabled();

    [CCode (cname = "ddca_get_display_refs")]
    public static Status get_display_refs(bool include_invalid_displays, out DisplayRef[] drefs_loc);

    [CCode (cname = "ddca_get_display_info")]
    public static Status get_display_info(DisplayRef ddca_dref, out DisplayInfo dinfo_loc);

    [CCode (cname = "ddca_free_display_info")]
    public static void free_display_info(DisplayInfo info_rec);

    [CCode (cname = "ddca_get_display_info_list2", has_target = false)]
    public static Status get_display_info_list2(bool include_invalid_displays, out DisplayInfoList dlist_loc);

    [CCode (cname = "DDCA_Display_Info_List", destroy_function = "ddca_free_display_info_list")]
    public struct DisplayInfoList {
        [CCode (array_length_cname = "ct", array_length_type = "int")]
        public DisplayInfo[] info;
    }

    [CCode (cname = "ddca_free_display_info_list")]
    public static void free_display_info_list(DisplayInfoList dlist);

    [CCode (cname = "ddca_report_display_info")]
    public static void report_display_info(DisplayInfo dinfo, int depth);

    [CCode (cname = "ddca_report_display_info_list")]
    public static void report_display_info_list(DisplayInfoList dlist, int depth);

    [CCode (cname = "ddca_report_displays")]
    public static int report_displays(bool include_invalid_displays, int depth);

    [CCode (cname = "ddca_redetect_displays")]
    public static Status redetect_displays();

    [CCode (cname = "ddca_create_dispno_display_identifier")]
    public static Status create_dispno_display_identifier(int dispno, out DisplayIdentifier did_loc);

    [CCode (cname = "ddca_create_busno_display_identifier")]
    public static Status create_busno_display_identifier(int busno, out DisplayIdentifier did_loc);

    [CCode (cname = "ddca_create_mfg_model_sn_display_identifier")]
    public static Status create_mfg_model_sn_display_identifier(string mfg_id, string model, string sn, out DisplayIdentifier did_loc);

    [CCode (cname = "ddca_create_edid_display_identifier")]
    public static Status create_edid_display_identifier(uint8[] edid, out DisplayIdentifier did_loc);

    [CCode (cname = "ddca_create_usb_display_identifier")]
    public static Status create_usb_display_identifier(int bus, int device, out DisplayIdentifier did_loc);

    [CCode (cname = "ddca_create_usb_hiddev_display_identifier")]
    public static Status create_usb_hiddev_display_identifier(int hiddev_devno, out DisplayIdentifier did_loc);

    [CCode (cname = "ddca_free_display_identifier")]
    public static Status free_display_identifier(DisplayIdentifier did);

    [CCode (cname = "ddca_did_repr")]
    public static string did_repr(DisplayIdentifier did);

    [CCode (cname = "ddca_get_display_ref")]
    public static Status get_display_ref(DisplayIdentifier did, out DisplayRef dref_loc);

    [CCode (cname = "ddca_free_display_ref")]
    public static Status free_display_ref(DisplayRef dref);

    [CCode (cname = "ddca_dref_repr")]
    public static string dref_repr(DisplayRef dref);

    [CCode (cname = "ddca_dbgrpt_display_ref")]
    public static void dbgrpt_display_ref(DisplayRef dref, int depth);

    [CCode (cname = "ddca_open_display2")]
    public static Status open_display2(DisplayRef ddca_dref, bool wait, out DisplayHandle ddca_dh_loc);

    [CCode (cname = "ddca_close_display")]
    public static Status close_display(DisplayHandle ddca_dh);

    [CCode (cname = "ddca_dh_repr")]
    public static string dh_repr(DisplayHandle ddca_dh);

    [CCode (cname = "ddca_set_non_table_vcp_value")]
    public static Status set_non_table_vcp_value(DisplayHandle ddca_dh, VcpFeatureCode feature_code, uint8 hi_byte, uint8 lo_byte);

    [CCode (cname = "ddca_get_non_table_vcp_value")]
    public static Status get_non_table_vcp_value(DisplayHandle ddca_dh, VcpFeatureCode feature_code, out NonTableVcpValue valrec);
}
