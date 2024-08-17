apt update
apt install -y vim
apt install -y wget
apt install -y xz-utils
apt install -y git
apt install -y libx11-dev
apt install -y libgl1
apt install -y libgl-dev
apt install -y libxcursor-dev
apt install -y libxrandr-dev
apt install -y libxinerama-dev
apt install -y 	libxi-dev
cd /
wget https://github.com/raysan5/raylib/archive/refs/tags/5.0.tar.gz
tar -xf 5.0.tar.gz
wget https://ziglang.org/download/0.12.0/zig-linux-aarch64-0.12.0.tar.xz
tar -xJf zig-linux-aarch64-0.12.0.tar.xz
cd raylib-5.0/
/zig-linux-aarch64-0.11.0/zig build
cp -r zig-out/* /out/