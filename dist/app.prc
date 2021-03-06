CR    ���ܠx  @  default var TouchMode = {
    cancel: 0,
    press: 1, // 长按
    move: 2,  // 移动
}

App({
    page: "pages/backlight/backlight",

    /* app 加载完成触发该函数 */
    onLaunch: function (e) {

    },

    onShow: function (e) {

    },

    onHide: function () {

    },

    /* app 退出触发该函数 */
    onExit: function () {

    },

});

PageTouchInit = function (page) {
    page.touchStartY = 0;// panel中触摸的Y坐标
    page.touchStartPosition = 0;// page中开始触摸的坐标
    page.touchEndPosition = 0;// page中结束触摸的坐标
    page.touchStatus = TouchMode.cancel;
    page.touchTimer = 0;
    page.navigateEnable = true;
}

PageTouchUninit = function (page) {
    var that = page;
    if (that.touchTimer != 0) {
        clearInterval(that.touchTimer);
        that.touchTimer = 0;
    }
}

PageTouchEvent = function (page, event, longPress, R2L, L2R, T2D, D2T) {
    var that = page;
    var touchItem = event.touchs[0];

    if (touchItem.type == "touchstart") {
        //console.log(" >>> touchStart")
        /**长按操作**/
        that.touchStatus = TouchMode.press;
        that.touchStartPosition = { x: touchItem.x, y: touchItem.y };
        //console.log("that.touchTimer: ", that.touchTimer);
        if (that.touchTimer != 0) {
            clearInterval(that.touchTimer);
            that.touchTimer = 0;
        }

        that.touchTimer = setTimeout(function () {
            //console.log(">> long press");
            clearInterval(that.touchTimer);
            that.touchTimer = 0;
            if (that.touchStatus == TouchMode.press) {
                if (typeof (longPress) == "function") {
                    longPress();
                }
            }
        }, 1000);

    } else if (touchItem.type == "touchmove") {
        //console.log(" >>> touch move")
        that.touchStatus = TouchMode.move;
        that.touchEndPosition = { x: touchItem.x, y: touchItem.y };
    } else if (touchItem.type == "touchend") {
        console.log(" >>> touch end")
        if (that.touchStatus == TouchMode.move) {
            var d_ValueX = that.touchEndPosition.x - that.touchStartPosition.x
            var d_ValueY = that.touchEndPosition.y - that.touchStartPosition.y
           // console.log(" x : " + d_ValueX);
           // console.log(" y : " + d_ValueY);
           // console.log("  that.navigateEnable : " +  that.navigateEnable);
            if (d_ValueY > 50 && that.navigateEnable == true) {
                console.log("slide down")
                if (typeof (T2D) == "function") {
                    T2D();
                    return;
                }
            } else if (d_ValueY < -50 && that.navigateEnable == true) {
                console.log("slide up")
                if (typeof (D2T) == "function") {
                    D2T();
                    return;
                }
            }

            if (d_ValueX > 50 && that.navigateEnable == true) {
                console.log("slide right")
                if (typeof (L2R) == "function") {
                    L2R();
                    return;
                }
            } else if (d_ValueX < -50 && that.navigateEnable == true) {
                console.log("slide left")
                if (typeof (R2L) == "function") {
                    R2L();
                    return;
                }
            }
        }
        that.touchStatus = TouchMode.cancel;
        if (that.touchTimer != 0) {
            clearInterval(that.touchTimer);
            that.touchTimer = 0;
        }
    } else if (touchItem.type == "touchcancel") {
        if (that.touchTimer != 0) {
            clearInterval(that.touchTimer);
            that.touchTimer = 0;
        }
    }
}
  {
    "id"     : "com.example.backlight",
    "name"   : "@app_name",
    "author" : "rt-thread",
    "vendor" : "rt-thread",
    "version": "v1.0.0",
    "tag":[ "app" ],
    "apiLevel": {
        "min": 3, 
        "target": 3
    },
    "icon"  : "app.png"
}
 /* JS API For HardWare */

var dcmlib = require("dcm");
var emqlib = require("emq");

var data_pool;

var ID_VBAT_READ = 0x0601;

var ID_LCD_ON = 0x0621;
var ID_LCD_OFF = 0x0622;
var ID_LCD_SET_MODE = 0x0623;
var ID_LCD_SET_BRIGHTNESS = 0x0624;

var ID_TP_ON = 0x0631;
var ID_TP_OFF = 0x0632;

var ID_REBOOT = 0x0641;
var ID_SHUTDOWN = 0x0642;
var ID_VIBRATE = 0x0643;
var ID_SYSINFO = 0x0644;

var emq_key_channel = "hws.0";
var emq_rtc_channel = "hws.1";
var emq_tp_channel = "hws.2";
var emq_lcd_channel = "hws.3";
var emq_pm_channel = "hws.4";


var dcm_pool_name = "hws";

var realtime_dcm_name = "realtime";
var lcdpower_dcm_name = "lcdpower";
var lcdmode_dcm_name = "lcdmode";
var brightness_dcm_name = "brightness"
var tppower_dcm_name = "tppower"
var battery_dcm_name = "battery"
var charge_dcm_name = "charge"
var vibstart_dcm_name = "vibstart"
var vibstop_dcm_name = "vibstop"
var vibcount_dcm_name = "vibcount"
var vibrate_dcm_name = "vibrate"
var sysinfo_dcm_name = "sysinfo"

var key_change_arr = [];
var screen_func_arr = [];
var touch_func_arr = [];
var battery_func_arr = [];
var charge_func_arr = [];
var realtime_func_arr = [];

/* 开启监听：增加onChange事件 */
function emqHWOnChange(func_arr, onChange, emq_channel)
{
    var obj =
    {
        fun : null,
        ep : null
    };

    if (func_arr == null)
    {
        ////console.log("emqHWOnChange: func_arr is null!")
        return false;
    }

    if (onChange == null)
    {
        //console.log("emqHWOnChange: onChange is null!")
        return false;
    }

    if (emq_channel == null)
    {
        //console.log("emqHWOnChange: emq_channel is null!")
        return false;
    }

    func_arr.forEach(function(x, index, a)
    {
        if (onChange == func_arr[index].fun)
        {
            //console.log("emq onChange func exists!")
            return true;
        }
    })

    obj.fun = onChange
    obj.ep =  emqlib.createEP();
    obj.ep.onMessage(emq_channel, onChange);

    func_arr.push(obj);
    //console.log("add onChange OK!")

    return true;
}

/* 取消监听：取消onChange事件 */
function emqHWOffChange(func_arr, onChange)
{
    //console.log("emqHWOffChange")

    if (func_arr == null)
    {
        //console.log("emqHWOffChange: func_arr is null!")
        return false;
    }

    if (onChange == null)
    {
        //console.log("emqHWOffChange: onChange is null!")
        return false;
    }

    func_arr.forEach(function(x, index, a)
    {
        if (onChange == func_arr[index].fun)
        {
            func_arr.splice(index, 1);

            return true;
        }
    })

    return true;
}

/* 开启监听：DCM 数据 改变 */
function dcmHWOnChange(func_arr, onChange, dcm_name)
{
    var obj =
    {
        name : null,
        fun : null,
        pool : null
    };

    if (func_arr == null)
    {
        //console.log("dcmHWOnChange: func_arr is null!")
        return false;
    }

    if (onChange == null)
    {
        //console.log("dcmHWOnChange: onChange is null!")
        return false;
    }

    if (dcm_name == null)
    {
        //console.log("dcmHWOnChange: dcm_name is null!")
        return false;
    }

    func_arr.forEach(function(x, index, a)
    {
        if (onChange == func_arr[index].fun)
        {
            //console.log("dcm onChange func exists!")
            return true;
        }
    })

    obj.name = dcm_name;
    obj.fun = onChange;
    obj.pool = dcmlib.Open(dcm_pool_name);
    obj.pool.onChange(dcm_name, onChange);

    func_arr.push(obj);
    //console.log("dcm add onChange OK!")

    return true;
}

/* 取消监听：DCM 数据 改变 */
function dcmHWOffChange(func_arr, onChange)
{
    //console.log("dcmOffChange")

    if (func_arr == null)
    {
        //console.log("dcmHWOffChange: func_arr is null!")
        return false;
    }

    if (onChange == null)
    {
        //console.log("dcmHWOffChange: onChange is null!")
        return false;
    }

    func_arr.forEach(function(x, index, a)
    {
        if (onChange == func_arr[index].fun)
        {
            var dcm_name = func_arr[index].name;
            func_arr[index].pool.offChange(dcm_name);
            func_arr.splice(index, 1);
            return true;
        }
    })

    return true;
}

function getRealTime()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var data = data_pool.getItem(realtime_dcm_name);

    if (data == null || data == "undefine")
    {
        data_pool.setItem(realtime_dcm_name, "1601366586");
        data = data_pool.getItem(realtime_dcm_name);
    }

    return data;
}

function setRealTime(time)
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var data = data_pool.getItem(realtime_dcm_name);
    if (data == null || data == "undefine")
    {
        //console.log("getItem null or undefine")
        data_pool.setItem(realtime_dcm_name, time);
    }

    //console.log("setRealTime");

    return true;
}

/* 开启监听：realtime改变 */
function onRealTimeChange(onChange)
{
    return dcmHWOnChange(realtime_func_arr, onChange, realtime_dcm_name);
}

/* 取消监听：realtime改变 */
function offRealTimeChange(onChange)
{
    return dcmHWOffChange(realtime_func_arr, onChange);
}

/* 获取屏幕电源状态 */
function getScreenStatus()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var lcdpower = data_pool.getItem(lcdpower_dcm_name);

    //console.log("getScreenStatus");
    if (lcdpower != null)
    {
        return lcdpower;
    }

    return 0;
}

/* 获取屏幕模式 */
function getScreenMode()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var lcdmode = data_pool.getItem(lcdmode_dcm_name);
    if (lcdmode != null)
    {
        console.log("getScreenMode:" + lcdmode);
        return lcdmode;
    }

    return null;
}

/* 设置屏幕模式 */
function setScreenMode(mode)
{
    data_pool = dcmlib.Open(dcm_pool_name);
    data_pool.setItem(lcdmode_dcm_name, mode);

    emqlib.send(emq_lcd_channel, ID_LCD_SET_MODE);
    console.log("[hardware.js] setScreenMode");

    return 0;
}

/* 打开屏幕 */
function openScreen()
{
    //console.log("---------" + msgid.MSG_ID_LCD_ON)
    emqlib.send(emq_lcd_channel, ID_LCD_ON);

    //console.log("openScreen");

    return true;
}

/* 关闭屏幕 */
function closeScreen()
{
    emqlib.send(emq_lcd_channel, ID_LCD_OFF);

    //console.log("closeScreen");

    return true;
}

/* 开启监听：屏幕状态改变 */
function onScreenStatusChange(onChange)
{
    return dcmHWOnChange(screen_func_arr, onChange, lcdpower_dcm_name);
}

/* 取消监听：屏幕状态改变 */
function offScreenStatusChange(onChange)
{
    //console.log("offScreenPowerChange");
    return dcmHWOffChange(screen_func_arr, onChange);
}

/* 获取屏幕亮度 */
function getScreenBrightness()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var brightness = data_pool.getItem(brightness_dcm_name);
    if (brightness != null)
    {
        return brightness;
    }

    //console.log("getScreenBrightness");

    return 0;
}

/* 设置屏幕亮度 */
function setScreenBrightness(bright)
{
    data_pool = dcmlib.Open(dcm_pool_name);
    data_pool.setItem(brightness_dcm_name, bright);

    emqlib.send(emq_lcd_channel, ID_LCD_SET_BRIGHTNESS);
    //console.log("setScreenBrightness:" + bright);

    return true;
}

/* 获取触摸屏电源状态 */
function getTouchPanelStatus()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var tppower = data_pool.getItem(tppower_dcm_name);
    if (tppower != null)
    {
        return tppower;
    }

    //console.log("getTouchPanelStatus");

    return 0;
}

/* 打开触摸屏电源 */
function openTouchPanel()
{
    emqlib.send(emq_tp_channel, ID_TP_ON);
    //console.log("openTouchPanel");

    return true;
}

/* 关闭触摸屏电源 */
function closeTouchPanel()
{
    emqlib.send(emq_tp_channel, ID_TP_OFF);
    //console.log("closeTouchPanel");

    return true;
}

/* 开启监听：触摸屏电源状态 */
function onTouchPanelStatusChange(onChange)
{
    return dcmHWOnChange(touch_func_arr, onChange, tppower_dcm_name);
}

/* 取消监听：触摸屏电源状态 */
function offTouchPanelStatusChange(onChange)
{
    //console.log("offTouchPanelPowerChange");
    return dcmHWOffChange(touch_func_arr, onChange);
}

/* 获取电量 */
function getBatteryLevel()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var level = data_pool.getItem(battery_dcm_name);
    if (level != null)
    {
        return level;
    }

    //console.log("getBatteryLevel");

    return 0;
}

/* 开启监听：电量变化 */
function onBatteryLevelChange(onChange)
{
    //console.log("onBatteryLevelChange")
    return dcmHWOnChange(battery_func_arr, onChange, battery_dcm_name);
}

/* 取消监听：电量变化 */
function offBatteryLevelChange(onChange)
{
    //console.log("offBatteryLevelChange");
    return dcmHWOffChange(battery_func_arr, onChange);
}

/* 获取充电状态 */
function getChargeStatus()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var status = data_pool.getItem(charge_dcm_name);
    if (status != null)
    {
        return status;
    }

    //console.log("getChargeStatus");

    return 0;
}

/* 开启监听：充电状态 */
function onChargeChange(onChange)
{
    //console.log("onChargeChange")
    return dcmHWOnChange(charge_func_arr, onChange, charge_dcm_name);
}

/* 取消监听：充电状态 */
function offChargeChange(onChange)
{
    //console.log("offChargeChange");
    return dcmHWOffChange(charge_func_arr, onChange);
}

/* 系统重启 */
function reboot()
{
    emqlib.send(emq_pm_channel, ID_REBOOT);
    //console.log("reboot")

    return true;
}

/* 系统关机 */
function powerOff()
{
    emqlib.send(emq_pm_channel, ID_SHUTDOWN);
    //console.log("powerOff")

    return true;
}

/* 振动 */
function vibrate(start, stop, count)
{
    data_pool = dcmlib.Open(dcm_pool_name);

    data_pool.setItem(vibstart_dcm_name, start);
    data_pool.setItem(vibstop_dcm_name, stop);
    data_pool.setItem(vibcount_dcm_name, count);

    //console.log("vibrate")
    emqlib.send(emq_pm_channel, ID_VIBRATE);
    return true;
}

/* 开启监听：按键事件 */
function onKeyChange(onChange)
{
    return emqHWOnChange(key_change_arr, onChange, emq_key_channel);
}

/* 取消监听：按键事件 */
function offKeyChange(onChange)
{
    return emqHWOffChange(key_change_arr, onChange);
}

/* 获取系统信息 */
function getInfo()
{
    data_pool = dcmlib.Open(dcm_pool_name);
    var info = data_pool.getItem(sysinfo_dcm_name);
    if (info != null)
    {
        return info;
    }

    return null;
}

module.exports =
{
    getRealTime: getRealTime,
    setRealTime: setRealTime,
    onRealTimeChange:onRealTimeChange,
    offRealTimeChange:offRealTimeChange,
    getScreenStatus: getScreenStatus,
    getScreenMode: getScreenMode,
    setScreenMode: setScreenMode,
    openScreen: openScreen,
    closeScreen: closeScreen,
    onScreenStatusChange: onScreenStatusChange,
    offScreenStatusChange: offScreenStatusChange,
    getScreenBrightness: getScreenBrightness,
    setScreenBrightness: setScreenBrightness,
    getTouchPanelStatus: getTouchPanelStatus,
    openTouchPanel: openTouchPanel,
    closeTouchPanel: closeTouchPanel,
    onTouchPanelStatusChange: onTouchPanelStatusChange,
    offTouchPanelStatusChange: offTouchPanelStatusChange,
    getBatteryLevel: getBatteryLevel,
    onBatteryLevelChange: onBatteryLevelChange,
    offBatteryLevelChange: offBatteryLevelChange,
    getChargeStatus: getChargeStatus,
    onChargeChange: onChargeChange,
    offChargeChange: offChargeChange,
    reboot: reboot,
    powerOff: powerOff,
    vibrate: vibrate,
    onKeyChange: onKeyChange,
    offKeyChange: offKeyChange,
    getInfo: getInfo
}
  hws = require("modules/hardware.js");
var that = null;

Page({
    current_backlight: 60,
    /* 此方法在第一次显示窗体前发生 */
    onLoad: function (event) {
        PageTouchInit(this);
        that = this;

        var light = hws.getScreenBrightness();
        if (light == "undefine" || light == "null" || light > 100 || light < 0) {
            console.log("backlight illegal !!!")
        } else {
            that.current_backlight = light;
        }
        var light_number = that.current_backlight;
        that.setData({ voice_slider: { value: light_number } })
    },

    /* 此方法展示窗体前发生 */
    onShow: function (event) {

    },

    /* 此方法展示窗体后发生 */
    onResume: function (event) {

    },

    /* 此方法关闭窗体前发生 */
    onExit: function (event) {
        PageTouchUninit(this);
    },

    onPageTouch: function (event) {
        PageTouchEvent(this, event,
            0,
            0,
            function () { pm.navigateBack() },
            function () { that.add_func(5) },
            function () { that.sub_func(5) }
        );
    },

    add_func: function (data) {
        var new_value = that.current_backlight
        new_value = new_value + data;
        if (new_value >= 100) {
            new_value = 100;
        }
        that.current_backlight = new_value
        that.setData({ voice_slider: { value: that.current_backlight } });
        hws.setScreenBrightness(that.current_backlight);
    },

    sub_func: function (data) {
        console.log("sub_func" + data);
        var new_value = that.current_backlight
        new_value = new_value - data;
        if (new_value < 0) {
            new_value = 0;
        }
        that.current_backlight = new_value
        that.setData({ voice_slider: { value: that.current_backlight } });
        hws.setScreenBrightness(that.current_backlight);
    },

    onBtn: function (event) {
        var new_value = that.current_backlight;
        if (event.target.id == "add_button") {
            new_value = new_value + 5;
            if (new_value > 100) {
                new_value = 100;
            }
        }
        else if (event.target.id == "sub_button") {
            new_value = new_value - 5;
            if (new_value < 0) {
                new_value = 0;
            }
        }
        that.current_backlight = new_value
        that.setData({ voice_slider: { value: that.current_backlight } });

        hws.setScreenBrightness(that.current_backlight);
    },

    valueChanged: function (event) {
        console.log("valueChanged = " + that.current_backlight)
        that.current_backlight = event.detail.value;
        hws.setScreenBrightness(that.current_backlight);
    }

});

  <?xml version="1.0" encoding="UTF-8"?>
<rtgui version="1.0">
<class>Page</class>
<widget class="Page" bindtouch="onPageTouch" name="backlight">
<property name="enterAnim">AnimMoveLeft, 10, 10</property>
<property name="exitAnim">AnimMoveRight, 10, 10</property>
<public>
<property name="background">255, 255, 255, 255</property>
</public>
<widgets>
<widget name="voice_slider" class="slider" bindchange="valueChanged">
<public>
<property name="rect">100, 67, 40, 110</property>
<property name="background">0, 212, 208, 200</property>
</public>
<property name="minValue">0</property>
<property name="maxValue">100</property>
<property name="currentValue">0</property>
<property name="direction">VERTICAL</property>
<property name="norImg">images/slider_nor.png</property>
<property name="barImg">images/slider_bar.png</property>
<property name="sliderImg">images/slider_slider.png</property>
</widget>
<widget name="sub_button" class="button" bindtap="onBtn">
<public>
<property name="rect">96, 173, 48, 48</property>
<property name="align">HORIZONTAL | VERTICAL</property>
<property name="background">0, 255, 255, 255</property>
<property name="font">/system/fonts/HYQIHEI-55J.TTF, 16</property>
</public>
<property name="norImg">images/sub.png</property>
</widget>
<widget name="add_button" class="button" bindtap="onBtn">
<public>
<property name="rect">96, 19, 48, 48</property>
<property name="align">HORIZONTAL | VERTICAL</property>
<property name="background">0, 0, 0, 0</property>
<property name="font">/system/fonts/HYQIHEI-55J.TTF, 16</property>
</public>
<property name="norImg">images/add.png</property>
</widget>
</widgets>
</widget>
</rtgui>�PNG

   IHDR   0   0   W��   	pHYs     ��  
MiCCPPhotoshop ICC profile  xڝSwX��>��eVB��l� "#��Y�� a�@Ņ�
V�HUĂ�
H���(�gA��Z�U\8�ܧ�}z�����������y��&��j 9R�<:��OH�ɽ�H� ���g�  �yx~t�?��o  p�.$�����P&W  � �"��R �.T� � �S�d
 �  ly|B" � ��I> ة�� آ� � �(G$@� `U�R,�� ��@".���Y�2G�� v�X�@` ��B,�  8 C� L�0ҿ�_p��H �˕͗K�3���w����!��l�Ba)f	�"���#H�L�  ����8?������f�l��Ţ�k�o">!����� N���_���p��u�k�[ �V h��]3�	�Z
�z��y8�@��P�<
�%b��0�>�3�o��~��@��z� q�@������qanv�R���B1n��#�ǅ��)��4�\,��X��P"M�y�R�D!ɕ��2���	�w ��O�N���l�~��X�v @~�-�� g42y�  ����@+ ͗��  ��\��L�  D��*�A�������aD@$�<B�
��AT�:��������18��\��p`����	A�a!:�b��"���"aH4��� �Q"��r��Bj�]H#�-r9�\@���� 2����G1���Q�u@���Ơs�t4]���k��=�����K�ut }��c��1f��a\��E`�X&�c�X5V�5cX7v��a�$���^��l���GXLXC�%�#��W	��1�'"��O�%z��xb:��XF�&�!!�%^'_�H$ɒ�N
!%�2IIkH�H-�S�>�i�L&�m������ �����O�����:ň�L	�$R��J5e?���2B���Qͩ����:�ZIm�vP/S��4u�%͛Cˤ-��Кigi�h/�t�	݃E�З�k�����w���Hb(k{��/�L�ӗ��T0�2�g��oUX*�*|���:�V�~��TUsU?�y�T�U�^V}�FU�P�	��թU��6��RwR�P�Q_��_���c���F��H�Tc���!�2e�XB�rV�,k�Mb[���Lv�v/{LSCs�f�f�f��q�Ʊ��9ٜJ�!��{--?-��j�f�~�7�zھ�b�r�����up�@�,��:m:�u	�6�Q����u��>�c�y�	������G�m��������7046�l18c�̐c�k�i������h���h��I�'�&�g�5x>f�ob�4�e�k<abi2ۤĤ��)͔k�f�Ѵ�t���,ܬج��9՜k�a�ټ�����E��J�6�ǖږ|��M����V>VyV�V׬I�\�,�m�WlPW��:�˶�����v�m���)�)�Sn�1���
���9�a�%�m����;t;|rtu�vlp���4éĩ��Wgg�s��5�K���v�Sm���n�z˕��ҵ������ܭ�m���=�}��M.��]�=�A���X�q�㝧�����/^v^Y^��O��&��0m���[��{`:>=e���>�>�z�����"�=�#~�~�~���;�������y��N`������k��5��/>B	Yr�o���c3�g,����Z�0�&L�����~o��L�̶��Gl��i��})*2�.�Q�Stqt�,֬�Y�g��񏩌�;�j�rvg�jlRlc웸�����x��E�t$	�����=��s�l�3��T�tc��ܢ����˞w<Y5Y�|8����?� BP/O�nM򄛅OE����Q���J<��V��8�;}C�h�OFu�3	OR+y���#�MVD�ެ��q�-9�����Ri��+�0�(�Of++��y�m������#�s��l�Lѣ�R�PL/�+x[[x�H�HZ�3�f���#�|���P���ظxY��"�E�#�Sw.1]R�dxi��}�h˲��P�XRU�jy��R�ҥ�C+�W4�����n��Z�ca�dU�j��[V*�_�p�����F���WN_�|�ym���J����H��n��Y��J�jA�І����_mJ�t�zj��ʹ���5a5�[̶���6��z�]�V������&�ֿ�w{��;��켵+xWk�E}�n��ݏb���~ݸGwOŞ�{�{�E��jtolܯ���	mR6�H:p囀oڛ�w�pZ*�A��'ߦ|{�P������ߙ���Hy+�:�u�-�m�=���茣�^G���~�1�cu�5�W���(=��䂓�d���N?=ԙ�y�L��k]Q]�gCϞ?t�L�_�����]�p�"�b�%�K�=�=G~p��H�[o�e���W<�t�M�;����j��s���.]�y�����n&��%���v��w
�L�]z�x�����������e�m��`�`��Y�	�����Ӈ��G�G�#F#�����dΓ᧲���~V�y�s������K�X�����Ͽ�y��r﫩�:�#���y=�����}���ǽ�(�@�P���cǧ�O�>�|��/����%ҟ3    cHRM  z%  ��  ��  ��  u0  �`  :�  o�_�F   �IDATx���A
� @���.Y�j���>.���%Ed6�g�2OQ5�(�C       "ҏC�����P�i4���Q�K�_Z�[ �.5Kֳݜ��� �	�!L�j���/��m�"�(r��A 0�  �� <)kr�?�/�         �3`  �� 
_�a�;�    IEND�B`�  �PNG

   IHDR   \   \   ���X   	pHYs    ��~�  �IDATx��MhG��,=؇����
�!������|I�Sh!v�4%=�.5�پC[�u�Spi.I}	(؁��ڗ`�p���A�t����jwvv��w�J���@��3�=�y3ﭖ9�q���A (��x��?N �x�Y˵�8"B� �L�m�
 <�^)�=_�?-c��V_��k��X��|q 6�����Z.ް�S���,Ȣ{.E����+��/]���[�F��>}'Rץ���2 4��w��u}���UYbQc��l�գ��	#8-\p3Y�1Zi�b'�N��#81Fpb>���m`���s��
�������'��j���8��L��.=�Rإk�^�f�'�N��#81FpbH�Bk��=w�~
Γ�D��Hd�����?'災�l������{��]����	C���p���D�"�N�Q�o�s |�s�A��z�����d��Q��B�����u���)`���|>k��ڇs�@P����O;;��o��mG���N�L"�^9e"��~�?���{����k�@߅��"�ngIr��`H�(��큃>�� G���3�)��&��N||%��.��p��V���c!q�ᵋs �����Ć,G�j}������#D���b��ݜ��c��P?M����]X���J��9�B<�]ܚ��யN�%�?���i���}�'2��o|z]�G-��%�mK�����mw��,��uK8��b�����\b��	�Y�B�( ��L��l\�TE&����I�]x���Ga��A���1t���+��ǩ��b�|�b,���p)tv��5���I=�6����+��;ͥ5��u���Z v+�>>9����\���c҉��0�j��l�D�͕�`��I��8�ux�#lLUp^��i��߈B' �d>��~���!�_��O��(U��VD%�~�<��� _�Ih��Z`r�Ĥ*��x��H��R����pc)r�Ą��?r|~[��ڐ�
��_ /����퓦Kd��>�Y���0���I+�<9���nb��p9�*��W�9�j��t�}�Ǥ�$�بX^�O�������c�	y�"g����|�����*Oh3��W�X(������"֭��]���yrv_��_aio����w�����P9��{�y��`ETh 3�6]��:�+��Lh`�	�@A6��o��Ja��������[�dp�ы�=�"�;놮,�x��� IV<k�	�B	��n�P�"{�q�Dw��obv���'�$�(��]!P�*֣Z�(�G[Y$�}�=�����Q��R���9yT�p�p&�X� 
W�]�_q�EŜ��Ǖc%��4jQm����QT�7�褂�/9q�O���m�����.2��M|ɉ�ͨKN"K�	�L�V_e.��d6pQU`?���n㢪�E���pm\q&Ϥ����T�m�g,�Bj��vY��$��1�c'�NLO	����dNJ������d���n?<�N��#81Fpb�������]�4�X�ƛ^�iႯ��3f�����Z*��>4��VN�ƍ�PX��	�>��M��8\��T��9�%�ͨk��hDO�%����ͺ��f��e�D/Q�?�Q�Gܠ�,�9a�>Z3.��N�J ���M�F    IEND�B`��PNG

   IHDR         u.2   gAMA  ���a   tEXtSoftware Adobe ImageReadyq�e<   �IDAT8Oc� ��ң�l�ā@<�gR�����ف� �/,,��q��_;v��O	ްaÏ��̳ 3!F�F�г��>� �D5��� h�2�
0 [�l{(�Y�d�j����[@�A�>�QSS�9s�����***7�fkB� �Y�����]{{���'������qss{2b4`�X�K��2?�_ �" � ��@AAM� �!c4��O�    IEND�B`�  �PNG

   IHDR         k�w   gAMA  ���a   tEXtSoftware Adobe ImageReadyq�e<   �IDAT8Oc��c�� (q k�yx ;��������r�ob�$6����yvÆ��,Y��̙����� ŋ Ҙ�T�YCkk����4���;v����a�ĉ E� ң��6�u�O#�A�a�ƍ!khooe��iL�����5������@�15�q��������;jjj�B@$��q(�y�`x���� ��c4U    IEND�B`�  �PNG

   IHDR   
   
   PX�   gAMA  ���a   	pHYs  �  ���k�   tEXtSoftware paint.net 4.0.19�ֲd   &IDAT(S}ǡ  0���wXRARә����������t�m䈜Q    IEND�B`�   �PNG

   IHDR   
   
   PX�   gAMA  ���a   	pHYs  �  ���k�   tEXtSoftware paint.net 4.0.19�ֲd   IDAT(Sch�F���� �|�v�    IEND�B`��PNG

   IHDR         ;0��   gAMA  ���a   	pHYs  �  ��o�d   tEXtSoftware paint.net 4.0.19�ֲd  !IDATHK��YL�Uǿh��FLq���c��K�&�[�Z��*��Q��ФI-�O��Ĥ�����BI���O��Չ�5��}������;2��Or���r��l��M��������+����Dq*�*M&�����œ���'&&.ў~�ً �|����ozNIyV�%��P��>�m���K�����d��y�9�����E===K�����ղ���	e.i64i�6����op�H���?��Sf����A!��j����kt�����y���/�
?5{�ٓ�n��ܶ���F�N�eq����ʁ˽�삥�����*~2{�΁l:d��c������<?��Ǵ�Y{��0;���ĬW"���j91�to߸ٞ��
dѦj��p{��m����3�ُuﹹ;>p��[>1{��و.��	v���-�v[�@q�FYs���"��5���5�f����Zͱƞ����*]X�|j�� ���wy8'�̓;S܋��b�M�@�V�mv��k��X8�W5b��S�w����-������^,t�f\8Vg������5.��y���C����>�$%󆲗D"��E������[u���.\�euk&�!poo����)%C��b↢l ��ܨ�x��-K�c���b����P��r�E5Iɐ�K�6=8���c�b��3�i�?��;��#�ʂ�!c�)�e��
w���vx	�dt��}?+��1� g������8�򴌩�ՃHDR�������?�kN��G��{H��Z����zW��ja����
�{�e |���"A�*��7{X����+6�A$����Accc�LW��F��oa��(�'TN/c6�1��H$��O��mL�Oimt�	�%�p@�V8��f�[�8O �t����3����~
�a5�O�����a/�x�(k� �.-}}}�6ZZZV�;u�@?�~
�C��pb��l1g.m)�\�Qq�V���yk�T#uuuzX'b�m�9�&N?%��q;q�d,=3���R@a�ru�Y[��������K}}}^<��N����b9|�,� eB�1x&{Y#��K��������XYY��㯻��2�Y�r�&^�~J̩o. �r	��% ���b�{Ӗ"SSSmx��RSS�A�]�L�ĻF]k��P�� ��Q2d/���)"�Xyy�z�~q�ru��t���eE�� �?$
d�H1}yS����UG��҅RVVv���[�����D�:��аG:��Emm���ƽ�� ��u�C�=��imm}����"|yD
��F�/����[�m%###;������ߖ��_��/�u�F6    IEND�B`��PNG

   IHDR   0   0   W��   	pHYs     ��  
MiCCPPhotoshop ICC profile  xڝSwX��>��eVB��l� "#��Y�� a�@Ņ�
V�HUĂ�
H���(�gA��Z�U\8�ܧ�}z�����������y��&��j 9R�<:��OH�ɽ�H� ���g�  �yx~t�?��o  p�.$�����P&W  � �"��R �.T� � �S�d
 �  ly|B" � ��I> ة�� آ� � �(G$@� `U�R,�� ��@".���Y�2G�� v�X�@` ��B,�  8 C� L�0ҿ�_p��H �˕͗K�3���w����!��l�Ba)f	�"���#H�L�  ����8?������f�l��Ţ�k�o">!����� N���_���p��u�k�[ �V h��]3�	�Z
�z��y8�@��P�<
�%b��0�>�3�o��~��@��z� q�@������qanv�R���B1n��#�ǅ��)��4�\,��X��P"M�y�R�D!ɕ��2���	�w ��O�N���l�~��X�v @~�-�� g42y�  ����@+ ͗��  ��\��L�  D��*�A�������aD@$�<B�
��AT�:��������18��\��p`����	A�a!:�b��"���"aH4��� �Q"��r��Bj�]H#�-r9�\@���� 2����G1���Q�u@���Ơs�t4]���k��=�����K�ut }��c��1f��a\��E`�X&�c�X5V�5cX7v��a�$���^��l���GXLXC�%�#��W	��1�'"��O�%z��xb:��XF�&�!!�%^'_�H$ɒ�N
!%�2IIkH�H-�S�>�i�L&�m������ �����O�����:ň�L	�$R��J5e?���2B���Qͩ����:�ZIm�vP/S��4u�%͛Cˤ-��Кigi�h/�t�	݃E�З�k�����w���Hb(k{��/�L�ӗ��T0�2�g��oUX*�*|���:�V�~��TUsU?�y�T�U�^V}�FU�P�	��թU��6��RwR�P�Q_��_���c���F��H�Tc���!�2e�XB�rV�,k�Mb[���Lv�v/{LSCs�f�f�f��q�Ʊ��9ٜJ�!��{--?-��j�f�~�7�zھ�b�r�����up�@�,��:m:�u	�6�Q����u��>�c�y�	������G�m��������7046�l18c�̐c�k�i������h���h��I�'�&�g�5x>f�ob�4�e�k<abi2ۤĤ��)͔k�f�Ѵ�t���,ܬج��9՜k�a�ټ�����E��J�6�ǖږ|��M����V>VyV�V׬I�\�,�m�WlPW��:�˶�����v�m���)�)�Sn�1���
���9�a�%�m����;t;|rtu�vlp���4éĩ��Wgg�s��5�K���v�Sm���n�z˕��ҵ������ܭ�m���=�}��M.��]�=�A���X�q�㝧�����/^v^Y^��O��&��0m���[��{`:>=e���>�>�z�����"�=�#~�~�~���;�������y��N`������k��5��/>B	Yr�o���c3�g,����Z�0�&L�����~o��L�̶��Gl��i��})*2�.�Q�Stqt�,֬�Y�g��񏩌�;�j�rvg�jlRlc웸�����x��E�t$	�����=��s�l�3��T�tc��ܢ����˞w<Y5Y�|8����?� BP/O�nM򄛅OE����Q���J<��V��8�;}C�h�OFu�3	OR+y���#�MVD�ެ��q�-9�����Ri��+�0�(�Of++��y�m������#�s��l�Lѣ�R�PL/�+x[[x�H�HZ�3�f���#�|���P���ظxY��"�E�#�Sw.1]R�dxi��}�h˲��P�XRU�jy��R�ҥ�C+�W4�����n��Z�ca�dU�j��[V*�_�p�����F���WN_�|�ym���J����H��n��Y��J�jA�І����_mJ�t�zj��ʹ���5a5�[̶���6��z�]�V������&�ֿ�w{��;��켵+xWk�E}�n��ݏb���~ݸGwOŞ�{�{�E��jtolܯ���	mR6�H:p囀oڛ�w�pZ*�A��'ߦ|{�P������ߙ���Hy+�:�u�-�m�=���茣�^G���~�1�cu�5�W���(=��䂓�d���N?=ԙ�y�L��k]Q]�gCϞ?t�L�_�����]�p�"�b�%�K�=�=G~p��H�[o�e���W<�t�M�;����j��s���.]�y�����n&��%���v��w
�L�]z�x�����������e�m��`�`��Y�	�����Ӈ��G�G�#F#�����dΓ᧲���~V�y�s������K�X�����Ͽ�y��r﫩�:�#���y=�����}���ǽ�(�@�P���cǧ�O�>�|��/����%ҟ3    cHRM  z%  ��  ��  ��  u0  �`  :�  o�_�F   �IDATx���-�0��wI+`�G@1��=�7C�@@��*B�v��gf���N,���  �  �  �8�� ��4!d��k���
v�^p:���g�� �o��S����h�x�D���1k@�Wh*��A� ^n�OA��V��3`�D�0 �������@ @ �y  �� iۡ��
    IEND�B`�    ZzH      <t=j'      hello_world背光调节 CR    "�.
   �  �   m0\��    �   �[��  �/  �   s^���?  �
    ��ǽ�J  �  )  ��� Q  z  G  ��M�\  �  Z  �*a^xc  :  m  ��D��d  :  �  �:;��e  �   �  -�ֽ�f  �   �  M�,0g  �  �  0[%��l  �    �\F�lx  3   )  app.js app.json modules/hardware.js pages/backlight/backlight.js pages/backlight/backlight.xml res/images/add.png res/images/app.png res/images/scrollbar_handle_horizontal.9.png res/images/scrollbar_handle_vertical.9.png res/images/slider_bar.png res/images/slider_nor.png res/images/slider_slider.png res/images/sub.png res/values/strings.bin 