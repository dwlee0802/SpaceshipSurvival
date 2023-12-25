mera/Canvas/TravelProgressUI/SpaceshipIcon"]
layout_mode = 0
offset_left = -14.0
offset_top = 17.0
offset_right = 41.0
offset_bottom = 43.0
text = "00.00%"
horizontal_alignment = 1
vertical_alignment = 1

[node name="SpaceshipFlame" type="TextureRect" parent="Camera/Canvas/TravelProgressUI/SpaceshipIcon"]
self_modulate = Color(0.658824, 0, 0, 1)
layout_mode = 0
offset_left = -20.0
offset_top = 3.0
offset_bottom = 15.0
texture = ExtResource("7_6kouo")
expand_mode = 1

[node name="SpaceshipInnerFlame" type="TextureRect" parent="Camera/Canvas/TravelProgressUI/SpaceshipIcon/SpaceshipFlame"]
self_modulate = Color(1, 1, 0.568627, 1)
layout_mode = 0
offset_left = 3.0
offset_top = 3.0
offset_right = 19.0
offset_bottom = 11.0
texture = ExtResource("7_6kouo")
expand_mode = 1

[node name="AnimationPlayer" type="AnimationPlayer" parent="Camera/Canvas/TravelProgressUI/SpaceshipIcon/SpaceshipFlame"]
libraries = {
"": SubResource("AnimationLibrary_pr1aw")
}
autoplay = "spaceship_flame_animation"
speed_scale = 4.0

[node name="UnitPanelsUI" type="Control" parent="Camera/Canvas"]
layout_mode = 3
anchors_preset = 0
offset_left = 53.0
offset_top = 1.0
offset_right = 93.0
offset_bottom = 41.0

[node name="Survivor1" type="TextureRect" parent="Camera/Canvas/UnitPanelsUI"]
layout_mode = 0
offset_left = 428.0
offset_top = 69.0
offset_right = 478.0
offset_bottom = 119.0
texture = ExtResource("5_lwbxl")

[node name="Survivor2" type="TextureRect" parent="Camera/Canvas/UnitPanelsUI"]
layout_mode = 0
offset_left = 510.0
offset_top = 69.0
offset_right = 560.0
offset_bottom = 119.0
texture = ExtResource("5_lwbxl")

[node name="Survivor3" type="TextureRect" parent="Camera/Canvas/UnitPanelsUI"]
layout_mode = 0
offset_left = 588.0
offset_top = 69.0
offset_right = 638.0
offset_bottom = 119.0
texture = ExtResource("5_lwbxl")

[node name="Survivor4" type="TextureRect" parent="Camera/Canvas/UnitPanelsUI"]
layout_mode = 0
offset_left = 665.0
offset_top = 68.0
offset_right = 715.0
offset_bottom = 118.0
texture = ExtResource("5_lwbxl")

[node name="Survivor5" type="TextureRect" parent="Camera/Canvas/UnitPanelsUI"]
layout_mode = 0
offset_left = 741.0
offset_top = 68.0
offset_right = 791.0
offset_bottom = 118.0
texture = ExtResource("5_lwbxl")

[node name="SpaceshipStatusUI" type="Control" parent="Camera/Canvas"]
layout_mode = 3
anchors_preset = 0
offset_left = 1314.0
offset_top = 149.0
offset_right = 1354.0
offset_bottom = 189.0

[node name="OxygenLevel" type="TextureRect" parent="Camera/Canvas/SpaceshipStatusUI"]
self_modulate = Color(0, 1, 1, 1)
layout_mode = 0
offset_right = 40.0
offset_bottom = 40.0
texture = ExtResource("7_6kouo")
expand_mode = 1

[node name="Label" type="Label" parent="Camera/Canvas/SpaceshipStatusUI/OxygenLevel"]
layout_mode = 0
offset_left = -34.0
offset_top = 7.0
offset_right = 75.0
offset_bottom = 33.0
text = "100%"
horizontal_alignment = 1
vertical_alignment = 1

[node name="Title" type="Label" parent="Camera/Canvas/SpaceshipStatusUI/OxygenLevel"]
layout_mode = 0
offset_left = -62.0
offset_top = 7.0
offset_right = -3.0
offset_bottom = 33.0
text = "Oxygen"

[node name="TemperatureLevel" type="TextureRect" parent="Camera/Canvas/SpaceshipStatusUI"]
self_modulate = Color(0, 0.686275, 0, 1)
layout_mode = 0
offset_top = 55.0
offset_right = 40.0
offset_bottom = 95.0
texture = ExtResource("7_6kouo")
expand_mode = 1

[node name="Label" type="Label" parent="Camera/Canvas/SpaceshipStatusUI/TemperatureLevel"]
layout_mode = 0
offset_left = -2.0
offset_top = 8.0
offset_right = 41.0
offset_bottom = 34.0
text = "25"
horizontal_alignment = 1
vertical_alignment = 1

[node name="Title" type="Label" parent="Camera/Canvas/SpaceshipStatusUI/TemperatureLevel"]
layout_mode = 0
offset_left = -49.0
offset_top = 8.0
offset_right = 10.0
offset_bottom = 34.0
text = "Temp"

[node name="RadiationAlert" type="TextureRect" parent="Camera/Canvas/SpaceshipStatusUI"]
self_modulate = Color(0.666667, 1, 0.372549, 1)
layout_mode = 0
offset_left = 1.0
offset_top = 109.0
offset_right = 41.0
offset_bottom = 149.0
texture = ExtResource("7_6kouo")
expand_mode = 1

[node name="                                                                                                                                                                                        � �\� PK1�   �K1�                                                                                                                                                                                