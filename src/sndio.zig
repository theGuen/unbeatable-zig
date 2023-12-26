const std = @import("std");
const c = @cImport(@cInclude("soundio/soundio.h"));
fn sio_err(err: c_int) !void {
    switch (err) {
        0 => {},
        else => return error.Unknown,
    }
}
pub var mix: fn () f32 = undefined;
pub var exit: fn () bool = undefined;

fn audio_callback(maybe_outstream: ?[*]c.SoundIoOutStream, frame_count_min: c_int, frame_count_max: c_int) callconv(.C) void {
    _ = frame_count_min;
    const outstream = @ptrCast(*c.SoundIoOutStream, maybe_outstream);
    const layout = &outstream.layout;
    var frames_left = frame_count_max;

    while (frames_left > 0) {
        var frame_count = frames_left;
        var areas: [*]c.SoundIoChannelArea = undefined;
        sio_err(c.soundio_outstream_begin_write(maybe_outstream, @ptrCast([*]?[*]c.SoundIoChannelArea, &areas), &frame_count)) catch |err| std.debug.panic("write failed: {s}", .{@errorName(err)});
        if (frame_count == 0) break;
        var frame: c_int = 0;
        while (frame < frame_count) : (frame += 1) {
            {
                var channel: usize = 0;
                while (channel < @intCast(usize, layout.channel_count)) : (channel += 1) {
                    const sample = mix();

                    const channel_ptr = areas[channel].ptr;
                    const sample_ptr = &channel_ptr[@intCast(usize, areas[channel].step * frame)];
                    @ptrCast(*f32, @alignCast(@alignOf(f32), sample_ptr)).* = sample;
                }
            }
        }
        sio_err(c.soundio_outstream_end_write(maybe_outstream)) catch |err| std.debug.panic("end write failed: {s}", .{@errorName(err)});
        frames_left -= frame_count;
    }
}

pub fn startAudio() !void {
    const soundio = c.soundio_create();
    defer c.soundio_destroy(soundio);
    try sio_err(c.soundio_connect(soundio));
    c.soundio_flush_events(soundio);

    const default_output_index = c.soundio_default_output_device_index(soundio);
    if (default_output_index < 0) return error.NoOutputDeviceFound;

    const device = c.soundio_get_output_device(soundio, default_output_index) orelse return error.OutOfMemory;
    defer c.soundio_device_unref(device);

    std.debug.print("Output device: {s}\n", .{device.*.name});
    const outstream = c.soundio_outstream_create(device) orelse return error.OutOfMemory;
    outstream.*.sample_rate = 44100;
    defer c.soundio_outstream_destroy(outstream);
    outstream.*.format = c.SoundIoFormatFloat32NE;
    outstream.*.write_callback = audio_callback;
    std.debug.print("Output Samplerate: {d}hz\n", .{outstream.*.sample_rate});

    try sio_err(c.soundio_outstream_open(outstream));
    try sio_err(c.soundio_outstream_start(outstream));
    while (!exit()) {}
}
