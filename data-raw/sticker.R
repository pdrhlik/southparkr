library(hexSticker)

sysfonts::font_add(
	family = "South Park",
	regular = "sticker/southpark.ttf"
)

hexSticker::sticker(
	"sticker/southparkme.png",
	package = "southparkr",
	p_size = 18,
	p_y = 1.4,
	s_x = 1,
	s_y = 0.75,
	s_width = 0.6,
	p_color = "#673C1C", #"#F26F03",
	h_fill = "#DEB887",
	h_color = "#673C1C",
	filename = "sticker/southparkr-sticker.png",
	p_family = "South Park",
	u_size = 4,
	url = "https://github.com/pdrhlik/southparkr"
)
