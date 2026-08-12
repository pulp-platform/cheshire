import glob
import re
from PIL import Image

def frame_number(filename):
    m = re.search(r"frame(\d+)\.bmp$", filename)
    return int(m.group(1)) if m else -1

files = sorted(glob.glob("frame*.bmp"), key=frame_number)

if not files:
    raise RuntimeError("No frame*.bmp files found")

print(f"Found {len(files)} frames")

frames = []

for filename in files:
    with Image.open(filename) as img:
        frames.append(img.convert("RGB"))

frames[0].save(
    "vga.gif",
    save_all=True,
    append_images=frames[1:],
    duration=33,   # ca. 30 FPS
    loop=0
)

print("Created vga.gif")