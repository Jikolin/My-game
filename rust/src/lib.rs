use godot::prelude::*;


// #[derive(GodotClass)]
// #[class(base=Node)]
// struct MyNode {
//     base: Base<Node>,
// }

// #[godot_api]
// impl INode for MyNode {
//     fn init(base: Base<Node>) -> Self {
//         Self { base }
//     }
// }


struct MyExtension;


#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}