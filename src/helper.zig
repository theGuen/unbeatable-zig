const std = @import("std");
const process = std.process;
const ma = @import("miniaudio.zig");
const smplr = @import("sampler.zig");

pub fn loadCmdLineArgSamples(alloc:std.mem.Allocator,sampler:*smplr.Sampler)!void{
    var args = process.args();
    // skip my own exe name
    _ = args.skip();
    var i:usize=0;
    while (true){
        const arg1 = (try args.next(alloc) orelse {
            break;
        });   
        var b = try ma.loadAudioFile(alloc,arg1);
        sampler.load(b,i);
        i+=1;
        alloc.free(arg1);
    }
}

pub fn userInput(samplers:*smplr.Sampler)!void{ 
    while (true){
        var buf: [1000]u8 = undefined;
        // We need a 0 terminated string... how unpleasant
        for (buf) |_,ii| buf[ii] = 0;
        const stdin = std.io.getStdIn().reader();
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            const bla:[]u8 = user_input;
            if(ma.loadAudioFile(samplers.alloc,bla))|b|{
                samplers.load(b);
            }else |err|{
                std.debug.print("ERROR: {s}\n", .{@errorName(err)});
            }
        }
    }
}

pub fn StringHasSuffix(string:[]const u8,suffix:[]const u8)bool{
    var retval = true;
    if(suffix.len>string.len)return false;
    for(suffix)|c,i|{
        retval = retval and (string[string.len-suffix.len+i]==c);
    }
    return retval;
}