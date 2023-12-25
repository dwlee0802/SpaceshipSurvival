entoryUI/InventoryGrid" instance=ExtResource("8_l1l7c")]
layout_mode = 2

[node name="DraggableItemSlot21" parent="Camera/Canvas/InventoryUI/InventoryGrid" instance=ExtResource("8_l1l7c")]
layout_mode = 2

[node name="DraggableItemSlot22" parent="Camera/Canvas/InventoryUI/InventoryGrid" instance=ExtResource("8_l1l7c")]
layout_mode = 2

[node name="DraggableItemSlot23" parent="Camera/Canvas/InventoryUI/InventoryGrid" instance=ExtResource("8_l1l7c")]
layout_mode = 2

[node name="DraggableItemSlot24" parent="Camera/Canvas/InventoryUI/InventoryGrid" instance=ExtResource("8_l1l7c")]
layout_mode = 2

[node name="HeadSlot" type="Label" parent="Camera/Canvas/InventoryUI"]
layout_mode = 0
offset_left = 10.0
offset_top = 40.0
offset_right = 84.0
offset_bottom = 63.0
text = "Head Slot"

[node name="DraggableItem" parent="Camera/Canvas/InventoryUI/HeadSlot" instance=ExtResource("8_l1l7c")]
layout_mode = 1
offset_left = 20.0
offset_top = 30.0
offset_right = -4.0
offset_bottom = 57.0
type = 0

[node name="BodySlot" type="Label" parent="Camera/Canvas/InventoryUI"]
layout_mode = 0
offset_left = 10.0
offset_top = 120.0
offset_right = 84.0
offset_bottom = 143.0
text = "Body Slot"

[node name="DraggableItem" parent="Camera/Canvas/InventoryUI/BodySlot" instance=ExtResource("8_l1l7c")]
layout_mode = 1
offset_left = 20.0
offset_top = 30.0
offset_right = -4.0
offset_bottom = 57.0
type = 1

[node name="PrimarySlot" type="Label" parent="Camera/Canvas/InventoryUI"]
layout_mode = 0
offset_left = 10.0
offset_top = 200.0
offset_right = 105.0
offset_bottom = 223.0
text = "Primary Slot"

[node name="DraggableItem" parent="Camera/Canvas/InventoryUI/PrimarySlot" instance=ExtResource("8_l1l7c")]
layout_mode = 1
offset_left = 20.0
offset_top = 30.0
offset_right = -25.0
offset_bottom = 57.0
type