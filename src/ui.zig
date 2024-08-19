const std = @import("std");
const assert = std.debug.assert;

const ray = @cImport(@cInclude("raylibwrapper.h"));
const mn = @import("menu.zig");
const smplr = @import("sampler.zig");
const helper = @import("helper.zig");
const seq = @import("sequencer.zig");
const settings = @import("settings.zig");

pub fn drawWindow(samplers: *smplr.Sampler, menu: *mn.Menu, sequencer: *seq.Sequencer) !void {
    const screenWidth = 800;
    const screenHeight = 480;
    const maxDispSamples = settings.sampleRate * 5;
    var smplDisp: [780]c_int = undefined;
    var page_colors = [4]ray.Color{ ray.PURPLE, ray.GREEN, ray.SKYBLUE, ray.BEIGE };

    //_ = ray.SetGamepadMappings(@ptrCast(settings.gamePadMapping));
    ray.InitWindow(screenWidth, screenHeight, "ADC - Arcade Drum Center");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);
    const cols = 4;
    const rows = 16;
    var buttons: [cols * 4]ray.Rectangle = undefined;
    for (&buttons, 0..) |*b, i| {
        const ix = @as(f32, @floatFromInt(10 + (i % cols) * 10 + (i % cols) * 50));
        const iy = @as(f32, @floatFromInt(220 + (i / cols) * 10 + (i / cols) * 50));
        b.* = ray.Rectangle{ .x = ix, .y = iy, .width = 50, .height = 50 };
    }

    var btn_colors: [cols * rows]ray.Color = undefined;
    for (&btn_colors) |*b| {
        b.* = ray.GREEN;
    }
    var btn_colors_prev: [cols * rows]ray.Color = undefined;
    for (&btn_colors) |*b| {
        b.* = ray.GREEN;
    }

    var currentPad: usize = 0;
    var joyStickDetected: bool = false;

    var menuMode = false;
    var menuactive = false;
    var kbState = NewButtonStates();
    var gpState = NewButtonStates();
    while (!ray.WindowShouldClose() and !settings.exit) {
        currentPad = samplers.selectedSound;
        joyStickDetected = ray.IsGamepadAvailable(0);

        kbState.updateFromKeyboard();
        gpState.update();
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC Sample Display
        const showSample = true;
        var sbuf = samplers.sounds[currentPad].buffer;
        var sm: usize = 0;
        var em: usize = 0;
        var cm: f64 = 0;
        if (sbuf.len > 0 and showSample) {
            const smplCount = @min(sbuf[0].len, maxDispSamples);
            const scale = smplCount / 780;
            const realPos = samplers.sounds[currentPad].posf;

            const realStart = @as(usize, @intFromFloat(samplers.sounds[currentPad].start));
            const realEnd = @as(usize, @intFromFloat(samplers.sounds[currentPad].end));
            const tmp = @as(usize, @intFromFloat(realPos / @as(f64, @floatFromInt(maxDispSamples))));

            const offset = tmp * maxDispSamples;
            cm = (realPos - @as(f64, @floatFromInt(offset))) / @as(f64, @floatFromInt(scale));
            if (realStart > offset and realStart < offset + maxDispSamples) {
                sm = (realStart - offset) / scale;
            }
            if (realEnd > offset and realEnd < offset + maxDispSamples) {
                em = (realEnd - offset) / scale;
            } else {
                //TODO: not correct
                em = realEnd;
            }

            for (&smplDisp, 0..) |*y, i| {
                var val: f32 = 0;
                const from = @min(sbuf[0].len, offset + i * scale);
                const to = @min(sbuf[0].len, offset + i * scale + scale);
                for (sbuf[0][from..to], 0..) |d, j| {
                    const l = @abs(d);
                    const r = @abs(sbuf[1][j]);
                    val = @max((l + r), val);
                }
                y.* = @intFromFloat(@min(val * 50, 50));
            }
        } else {
            for (&smplDisp) |*y| y.* = 0;
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MOUSE press pad
        var mousePosition = ray.GetMousePosition();
        for (&buttons, 0..) |*b, i| {
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)) {
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
                    samplers.play(i, true);
                    btn_colors[i] = ray.ORANGE;
                    currentPad = i;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)) {
                    samplers.stop(i);
                    btn_colors[i] = ray.GREEN;
                }
            }
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MENU Display
        const padStr = std.fmt.allocPrint(std.heap.page_allocator, "Pad {d}", .{currentPad}) catch "";
        defer std.heap.page_allocator.free(padStr);
        const padString = @as([*c]u8, @constCast(@ptrCast(padStr)));

        //--------------------------------------------------------------------------------------------------------------------------
        ray.BeginDrawing();
        defer ray.EndDrawing();

        var cur_row: usize = 0;
        if (!sequencer.stepMode) {
            cur_row = @intCast(samplers.row);
        } else {
            cur_row = @intCast(sequencer.curBar);
        }
        //CALC_SEQ
        const sixteenth = sequencer.sixteenth(samplers.selectedSound, cur_row);
        for (0..sixteenth.len) |x| {
            if (sixteenth[x]) {
                btn_colors[x] = ray.ORANGE;
                btn_colors_prev[x] = ray.ORANGE;
            } else {
                btn_colors[x] = page_colors[cur_row / 4];
            }
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MENU INPUT
        if (kbState.isUp() or gpState.isUp()) {
            if (menuMode) {
                _ = menu.prev();
            } else {
                _ = samplers.decrementRow();
            }
        }
        if (kbState.isDown() or gpState.isDown()) {
            if (menuMode) {
                _ = menu.next();
            } else {
                _ = samplers.incrementRow();
            }
        }
        if (kbState.isRight() or gpState.isRight()) {
            _ = menu.right();
        }
        if (kbState.isLeft() or gpState.isLeft()) {
            _ = menu.left();
        }
        if (kbState.but_select or gpState.but_select) {
            if (menuMode) {
                _ = menu.enter();
            } else {
                menuMode = true;
                menuactive = true;
            }
        }
        if (kbState.but_start or gpState.but_start) {
            std.debug.print("leave\n", .{});
            const tmp = menu.leave();
            std.debug.print("leave {?} {?}\n", .{ tmp, menuactive });
            if (!menuactive) {
                menuMode = false;
            }
            std.debug.print("leave {?} {?}\n", .{ tmp, menuactive });
            menuactive = tmp;
            std.debug.print("leave {?} {?}\n", .{ tmp, menuactive });
        }

        //--------------------------------------------------------------------------------------------------------------------------
        // CALC PAD INPUT

        for (0..16) |i| {
            if (kbState.isPadPressed(i) or gpState.isPadPressed(i)) {
                currentPad = padPressed(i, cur_row, samplers, sequencer, &btn_colors);
            }
            if (kbState.isPadReleased(i) or gpState.isPadReleased(i)) {
                _ = padRelease(i, cur_row, samplers, sequencer, &btn_colors, &page_colors);
            }
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW WAV Display
        ray.ClearBackground(ray.BLACK);
        ray.DrawRectangleLines(10, 4, 780, 100, ray.WHITE);

        for (smplDisp, 0..) |y, x| {
            if (x < sm or x > em) {
                ray.DrawLine(@intCast(x + 10), 58 + y, @intCast(x + 10), 58 - y, ray.DARKGRAY);
            } else {
                ray.DrawLine(@intCast(x + 10), 58 + y, @intCast(x + 10), 58 - y, ray.WHITE);
            }
        }

        const sm_c = @as(c_int, @intCast(sm));
        const em_c = @as(c_int, @intCast(em));
        const ph = @as(c_int, @intFromFloat(cm));
        ray.DrawLine(10 + ph, 4, 10 + ph, 104, ray.RED);
        ray.DrawLine(10 + sm_c, 4, 10 + sm_c, 104, ray.ORANGE);
        ray.DrawLine(10 + em_c, 4, 10 + em_c, 104, ray.ORANGE);

        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW MENU Display
        //ray.DrawRectangle(10, 65, 210, 47, ray.GRAY);
        const mText = menu.current();
        const concatenated = try helper.SubString(std.heap.page_allocator, @constCast(mText), 30);
        defer std.heap.page_allocator.free(concatenated);
        if (!menuMode) {
            ray.DrawRectangleLines(10, 115, 780, 96, ray.WHITE);
        } else {
            ray.DrawRectangleLines(10, 115, 780, 96, ray.RED);
        }
        ray.DrawText(padString, 12, 125, 20, ray.WHITE);

        const jbt = JoystickButtonTest();
        ray.DrawText(ray.TextFormat("%d/%d", jbt.controllerNr,jbt.buttonNumber), 700, 125, 20, ray.WHITE);

        ray.DrawText(@ptrCast(@constCast(concatenated)), 12, 155, 45, ray.WHITE);
        if (joyStickDetected) {
            ray.DrawCircle(780, 130, 5, ray.GREEN);
        } else {
            ray.DrawCircle(780, 130, 5, ray.RED);
        }

        if (sequencer.recording) {
            ray.DrawCircle(780, 150, 5, ray.RED);
        } else {
            ray.DrawCircle(780, 150, 5, ray.GREEN);
        }
        if (sequencer.stepMode) {
            ray.DrawCircle(780, 170, 5, ray.RED);
        } else {
            ray.DrawCircle(780, 170, 5, ray.GREEN);
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW Buttons
        for (&buttons, 0..) |*b, i| {
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
        // DRAW Active Buttons (Gamepi)

        const i: c_int = @intCast(cur_row % 4);
        const ix = @as(c_int, 5);
        const iy = 215 + i * 10 + i * 50;
        if (!menuMode) {
            ray.DrawRectangleLines(ix, iy, 240, 60, ray.RED);
        } else {
            ray.DrawRectangleLines(ix, iy, 240, 60, ray.WHITE);
        }
        drawExtraElements();
    }
}

pub fn drawExtraElements() void {
    var ba = ray.Rectangle{ .x = 300, .y = 215, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&ba, ray.PURPLE);

    var bb = ray.Rectangle{ .x = 460, .y = 215, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bb, ray.VIOLET);
    ray.DrawText("Nudge", 460, 215, 25, ray.WHITE);

    var bc = ray.Rectangle{ .x = 620, .y = 215, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bc, ray.DARKPURPLE);
    ray.DrawText("Pad Mode", 620, 215, 25, ray.YELLOW);

    var bd = ray.Rectangle{ .x = 300, .y = 275, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bd, ray.GREEN);

    var be = ray.Rectangle{ .x = 460, .y = 275, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&be, ray.LIME);
    ray.DrawText("Mute", 460, 275, 25, ray.WHITE);

    var bf = ray.Rectangle{ .x = 620, .y = 275, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bf, ray.DARKGREEN);
    ray.DrawText("Menu Mode", 620, 275, 25, ray.WHITE);

    var bg = ray.Rectangle{ .x = 300, .y = 335, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bg, ray.SKYBLUE);

    var bh = ray.Rectangle{ .x = 460, .y = 335, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bh, ray.BLUE);

    var bi = ray.Rectangle{ .x = 620, .y = 335, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bi, ray.DARKBLUE);
    ray.DrawText("Step Mode", 620, 335, 25, ray.WHITE);

    var bj = ray.Rectangle{ .x = 300, .y = 395, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bj, ray.BEIGE);

    var bk = ray.Rectangle{ .x = 460, .y = 395, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bk, ray.BROWN);

    var bl = ray.Rectangle{ .x = 620, .y = 395, .width = 150, .height = 50 };
    ray.WrapDrawRectangleRec(&bl, ray.DARKBROWN);
    ray.DrawText("SEQ Mode", 620, 395, 25, ray.WHITE);
}

pub fn padPressed(i: usize, r: usize, samplers: *smplr.Sampler, sequencer: *seq.Sequencer, btn_colors: []ray.Color) usize {
    var currentPad = i + (4 * r);
    if (currentPad > 63) {
        currentPad = currentPad - 64;
    }
    const pad_color_index = currentPad - ((r / 4) * 16);
    btn_colors[pad_color_index] = ray.ORANGE;
    if (!sequencer.stepMode) {
        if (sequencer.prepared) {
            _ = sequencer.startRecording();
            sequencer.prepared = false;
        }
        samplers.play(currentPad, true);
        sequencer.appendToRecord(currentPad);
    } else {
        btn_colors[pad_color_index] = ray.RED;
        sequencer.toggle(samplers.selectedSound, @intCast(currentPad * (settings.ppq / 4)));
    }
    return currentPad;
}

pub fn padRelease(i: usize, r: usize, samplers: *smplr.Sampler, sequencer: *seq.Sequencer, btn_colors: []ray.Color, page_colors: []ray.Color) usize {
    _ = sequencer;
    var currentPad = i + (4 * r);
    if (currentPad > 63) {
        currentPad = currentPad - 64;
    }
    const pad_color_index = currentPad - ((r / 4) * 16);
    samplers.stop(currentPad);
    btn_colors[pad_color_index] = page_colors[r / 4];
    return currentPad;
}

//--------------------------------------------------------------------------------------------------------------------------
const ButtonStates = struct {
    left: bool,
    right: bool,
    up: bool,
    down: bool,
    but_a: bool,
    but_a_rel: bool,
    but_b: bool,
    but_b_rel: bool,
    but_x: bool,
    but_x_rel: bool,
    but_y: bool,
    but_y_rel: bool,
    but_start: bool,
    but_select: bool,

    // Previous states
    prev_left: bool,
    prev_right: bool,
    prev_up: bool,
    prev_down: bool,
    pads: [16]c_int,
    pressed_pads: [16]bool,
    released_pads: [16]bool,

    pub fn update(self: *ButtonStates) void {
        // Store current states as previous
        self.prev_left = self.left;
        self.prev_right = self.right;
        self.prev_up = self.up;
        self.prev_down = self.down;

        // Update current states
        const vx = ray.GetGamepadAxisMovement(0, ray.GAMEPAD_AXIS_LEFT_X);
        const vy = ray.GetGamepadAxisMovement(0, ray.GAMEPAD_AXIS_LEFT_Y);
        self.left = vx < 0;
        self.right = vx > 0;
        self.up = vy < 0;
        self.down = vy > 0;

        self.but_a = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_DOWN);
        self.but_a_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_DOWN);
        self.but_b = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT);
        self.but_b_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT);
        self.but_x = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_LEFT);
        self.but_x_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_LEFT);
        self.but_y = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_UP);
        self.but_y_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_UP);
        self.but_start = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_MIDDLE_RIGHT);
        self.but_select = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_MIDDLE_LEFT);
        self.pressed_pads[0] = self.but_a;
        self.released_pads[0] = self.but_a_rel;
        self.pressed_pads[1] = self.but_b;
        self.released_pads[1] = self.but_b_rel;
        self.pressed_pads[2] = self.but_x;
        self.released_pads[2] = self.but_x_rel;
        self.pressed_pads[3] = self.but_y;
        self.released_pads[3] = self.but_y_rel;
    }

    pub fn isUp(self: *ButtonStates) bool {
        return self.up and !self.prev_up;
    }

    pub fn isUpReleased(self: *ButtonStates) bool {
        return !self.up and self.prev_up;
    }

    pub fn isDown(self: *ButtonStates) bool {
        return self.down and !self.prev_down;
    }

    pub fn isDownReleased(self: *ButtonStates) bool {
        return !self.down and self.prev_down;
    }

    pub fn isLeft(self: *ButtonStates) bool {
        return self.left and !self.prev_left;
    }

    pub fn isLeftReleased(self: *ButtonStates) bool {
        return !self.left and self.prev_left;
    }

    pub fn isRight(self: *ButtonStates) bool {
        return self.right and !self.prev_right;
    }

    pub fn isRightReleased(self: *ButtonStates) bool {
        return !self.right and self.prev_right;
    }

    pub fn isPadPressed(self: *ButtonStates, pad: usize) bool {
        return self.pressed_pads[pad];
    }
    pub fn isPadReleased(self: *ButtonStates, pad: usize) bool {
        return self.released_pads[pad];
    }

    pub fn updateFromKeyboard(self: *ButtonStates) void {
        self.left = false;
        self.right = false;
        self.up = false;
        self.down = false;

        self.prev_left = false;
        self.prev_right = false;
        self.prev_up = false;
        self.prev_down = false;

        self.left = ray.IsKeyPressed(ray.KEY_LEFT);
        self.right = ray.IsKeyPressed(ray.KEY_RIGHT);
        self.up = ray.IsKeyPressed(ray.KEY_UP);
        self.down = ray.IsKeyPressed(ray.KEY_DOWN);

        self.prev_left = ray.IsKeyReleased(ray.KEY_LEFT);
        self.prev_right = ray.IsKeyReleased(ray.KEY_RIGHT);
        self.prev_up = ray.IsKeyReleased(ray.KEY_UP);
        self.prev_down = ray.IsKeyReleased(ray.KEY_DOWN);

        self.but_a = ray.IsKeyPressed(ray.KEY_ONE);
        self.but_a_rel = ray.IsKeyReleased(ray.KEY_ONE);
        self.but_b = ray.IsKeyPressed(ray.KEY_TWO);
        self.but_b_rel = ray.IsKeyReleased(ray.KEY_TWO);
        self.but_x = ray.IsKeyPressed(ray.KEY_THREE);
        self.but_x_rel = ray.IsKeyReleased(ray.KEY_THREE);
        self.but_y = ray.IsKeyPressed(ray.KEY_FOUR);
        self.but_y_rel = ray.IsKeyReleased(ray.KEY_FOUR);
        self.but_start = ray.IsKeyPressed(ray.KEY_BACKSPACE);
        self.but_select = ray.IsKeyPressed(ray.KEY_ENTER);

        self.pressed_pads[0] = self.but_a;
        self.released_pads[0] = self.but_a_rel;
        self.pressed_pads[1] = self.but_b;
        self.released_pads[1] = self.but_b_rel;
        self.pressed_pads[2] = self.but_x;
        self.released_pads[2] = self.but_x_rel;
        self.pressed_pads[3] = self.but_y;
        self.released_pads[3] = self.but_y_rel;

        for (self.pads, 0..) |pad, i| {
            self.pressed_pads[i] = ray.IsKeyPressed(pad);
            self.released_pads[i] = ray.IsKeyReleased(pad);
        }
    }
};

fn NewButtonStates() ButtonStates {
    return ButtonStates{
        .left = false,
        .right = false,
        .up = false,
        .down = false,
        .but_a = false,
        .but_a_rel = false,
        .but_b = false,
        .but_b_rel = false,
        .but_x = false,
        .but_x_rel = false,
        .but_y = false,
        .but_y_rel = false,
        .but_start = false,
        .but_select = false,
        .prev_left = false,
        .prev_right = false,
        .prev_up = false,
        .prev_down = false,
        .pads = [16]c_int{ ray.KEY_ONE, ray.KEY_TWO, ray.KEY_THREE, ray.KEY_FOUR, ray.KEY_Q, ray.KEY_W, ray.KEY_E, ray.KEY_R, ray.KEY_A, ray.KEY_S, ray.KEY_D, ray.KEY_F, ray.KEY_Z, ray.KEY_X, ray.KEY_C, ray.KEY_V },
        .pressed_pads = [16]bool{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false },
        .released_pads = [16]bool{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false },
    };
}

const ControllerButtonRaw = struct {
        controllerNr: usize,
        buttonNumber: i64,
        axisNumber: i64,
        down:bool,
        move:bool,
};

fn JoystickButtonTest()ControllerButtonRaw{
        var retval = ControllerButtonRaw{ .controllerNr=0, .buttonNumber=-1, .axisNumber=-1, .down=false,.move=false};
        //8, 9
        //for (0..4) |i| // MAX_GAMEPADS = 4
        //{
            const i = 0;
            retval.controllerNr = i;
            if (ray.IsGamepadAvailable(@intCast(i))) {        
                for (0..@intCast(ray.GetGamepadAxisCount(@intCast(i)))) |axis| {
                    const xm = ray.GetGamepadAxisMovement(@intCast(i), @intCast(axis));
                    if (xm != 0){
                        retval.axisNumber = @intCast(axis);
                        retval.move = true;
                    }
                }
        
                for (0..32) |button| {
                    if(ray.IsGamepadButtonDown(@intCast(i), @intCast(button))){
                        retval.buttonNumber = @intCast(button);
                        retval.down = true;
                    }
                }
            }
        //}
        return retval;
}