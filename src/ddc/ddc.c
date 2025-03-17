#include "ddc.h"

#include <ddcutil_c_api.h>
#include <ddcutil_status_codes.h>

DDCA_Display_Info_List * dlist = NULL;
DDCA_Display_Handle dh = NULL;

int initDDC()
{
    if (dlist != NULL && dh != NULL)
    {
        return 1;
    }

    DDCA_Status status = ddca_get_display_info_list2(false, &dlist);

    if (status != DDCRC_OK || dlist->ct <= 0)
    {
        dlist = NULL;
        return 2;
    }

    DDCA_Display_Ref dref = dlist->info[0].dref;

    status = ddca_open_display2(dref, false, &dh);

    if (status != DDCRC_OK) {
        dlist = NULL;
        dh = NULL;
        return 3;
    }

    return 4;
}

void closeDDC()
{
    if (dh != NULL)
    {
        ddca_close_display(dh);
        dh = NULL;
    }

    if (dlist != NULL)
    {
        ddca_free_display_info_list(dlist);
        dlist = NULL;
    }
}

int getBrightness()
{
    DDCA_Vcp_Feature_Code feature_code = 0x10;

    DDCA_Non_Table_Vcp_Value vcpval;

    DDCA_Status status = ddca_get_non_table_vcp_value(dh, feature_code, &vcpval);

    if (status != DDCRC_OK)
    {
        return status;
    }

    return (int) vcpval.sh << 8 | vcpval.sl;
}

void setBrightness(int brightness)
{
    DDCA_Vcp_Feature_Code feature_code = 0x10;

    uint8_t hibyte = (brightness >> 8) & 0xFF;
    uint8_t lobyte = brightness & 0xFF;

    ddca_set_non_table_vcp_value(dh, feature_code, hibyte, lobyte);
}
