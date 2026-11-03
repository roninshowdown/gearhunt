class_name UiTheme
extends RefCounted
## Single source of truth for fonts, colours and panel styling.

const FONT_REGULAR := preload("res://assets/fonts/fredoka-latin-500-normal.woff2")
const FONT_BOLD := preload("res://assets/fonts/fredoka-latin-700-normal.woff2")
const BG := Color(0.05, 0.07, 0.13, 0.92)
const BG_LIGHT := Color(0.12, 0.17, 0.27, 0.95)
const ACCENT := Color(0.42, 0.95, 0.8)
const WARM := Color(1.0, 0.75, 0.32)
const DANGER := Color(1.0, 0.36, 0.36)
const TEXT := Color(0.94, 0.96, 1.0)
const MUTED := Color(0.64, 0.7, 0.8)


static func build() -> Theme:
	var theme := Theme.new()
	theme.default_font = FONT_REGULAR
	theme.default_font_size = 26
	theme.set_color("font_color", "Label", TEXT)
	theme.set_stylebox("panel", "PanelContainer", box(BG, ACCENT.darkened(0.55), 18))
	var button := "Button"
	theme.set_stylebox("normal", button, box(BG_LIGHT, Color(1, 1, 1, 0.1), 14))
	theme.set_stylebox("hover", button, box(BG_LIGHT.lightened(0.14), ACCENT, 14))
	theme.set_stylebox("focus", button, box(Color(0, 0, 0, 0), ACCENT, 14))
	theme.set_stylebox("pressed", button, box(ACCENT.darkened(0.5), ACCENT, 14))
	theme.set_stylebox("disabled", button, box(BG, Color(1, 1, 1, 0.05), 14))
	theme.set_color("font_color", button, TEXT)
	theme.set_color("font_hover_color", button, Color.WHITE)
	theme.set_color("font_disabled_color", button, MUTED.darkened(0.3))
	theme.set_font_size("font_size", button, 28)
	var field := box(BG_LIGHT, Color(1, 1, 1, 0.14), 12)
	theme.set_stylebox("normal", "LineEdit", field)
	theme.set_stylebox("focus", "LineEdit", box(Color(0, 0, 0, 0), ACCENT, 12))
	return theme


static func box(fill: Color, border: Color, radius: int, border_width: int = 3) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(18.0)
	style.anti_aliasing = true
	return style


static func label(text: String, size: int = 26, color: Color = TEXT, bold: bool = false) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", size)
	result.add_theme_color_override("font_color", color)
	if bold:
		result.add_theme_font_override("font", FONT_BOLD)
	return result


static func button(text: String, on_press: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(0, 66)
	result.pressed.connect(on_press)
	return result
