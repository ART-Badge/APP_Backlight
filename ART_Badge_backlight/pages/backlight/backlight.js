hws = require("modules/hardware.js");
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

