# scripts/main.gd
extends Node2D

# @onready - переменная инициализируется при готовности сцены
@onready var camera = $MainCamera
@onready var bg = $Background
@onready var container = $AchievementContainer

var map_size = Vector2(2000, 2000)  # Начальный размер карты

func _ready():
	# Настраиваем фон
	bg.size = map_size
	bg.color = Color.WHITE
	
	# Центрируем камеру
	camera.position = map_size / 2
	camera.zoom = Vector2(1, 1)  # Масштаб 100%
