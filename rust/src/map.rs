use godot::prelude::*;
use godot::classes::{GridMap, MeshLibrary};

use rand::RngExt;
use rand::seq::SliceRandom;


#[derive(Clone, Debug)]
struct Pos {                     //Posiiton
    y: usize,
    x: usize
}

#[derive(Clone, Debug)]
struct Direction {
    y: isize, 
    x: isize
}

impl Direction {
    fn all() -> [Self; 4] {
        [Self{y: -1, x: 0}, Self{y: 0, x: 1}, Self{y: 1, x: 0}, Self{y: 0, x: -1}]
    }
}

#[derive(Clone)]
struct PossCell {                // Possible Cell
    bridge: Pos, 
    room: Pos
}

#[derive(Clone)]
enum Cell {
    Room, 
    Bridge, 
    Wall, 
    Start,
}

enum CellState {
    Free,                        // Wall
    Used{cell: Cell},                        // Anything but not Wall
    OutOfGrid,
}


#[derive(GodotClass)]
#[class(base=Node3D)]
struct Floor {
    base: Base<Node3D>,
    width: usize, 
    height: usize, 
    s_cell: Pos,
    grid: Vec<Vec<Cell>>
}


#[godot_api]
impl INode3D for Floor {
    fn init(base: Base<Node3D>) -> Self {
        Self { 
            base,
            width: 1,
            height: 1,
            s_cell: Pos{ y: 0, x: 0 },
            grid: vec![vec![Cell::Wall; 1]],
         }
    }
}


#[godot_api]
impl Floor {
    #[func]
    fn setup(&mut self, width: i32, height: i32) {
        let width = width as usize;
        let height = height as usize;
        self.width = width;
        self.height = height;

        self.grid = vec![vec![Cell::Wall; width]; height];
        self.s_cell = Pos{
            y: rand::rng().random_range(0..height),
            x: rand::rng().random_range(0..width) 
        };

        self.generate_labyrinth();
        self.print();
    }

    #[func]
    fn build_grid(&self, position: Vector3) -> Gd<GridMap> {
        let mut grid = GridMap::new_alloc();
        grid.set_cell_size(Vector3::new(1.0, 0.375, 1.0));
        grid.set_position(position);
        let mesh_lib: Gd<MeshLibrary> = load("res://assets/map/labyrinth.tres");
        grid.set_mesh_library(&mesh_lib);
        for y in 0..self.height {
            for x in 0..self.width {
                match self.get_cell(&Pos{y, x}) {
                    Cell::Room => grid.set_cell_item(Vector3i::new(x as i32, 0, y as i32), 1),
                    Cell::Bridge => grid.set_cell_item(Vector3i::new(x as i32, 1, y as i32), 0),
                    _ => {}
                }
            }
        }
        grid
    }
}


impl Floor {
    fn print(&self) {
        println!("\n");
        print!("    ");
        for col in 0..self.width {
            print!("{:2} ", col);
        }
        println!();
        for row_i in 0..self.height {
            print!("{:2} | ", row_i);

            for col_i in 0..self.width {
                let cell = &self.grid[row_i][col_i];
                match cell {
                    Cell::Room => print!("@  "),
                    Cell::Bridge => print!("%  "),
                    Cell::Wall => print!("#  "),
                    Cell::Start => print!("S  ")
                }
            }
            println!();
        }
    }


    fn change_cell(&mut self, cell: &Pos, cell_type: Cell) {
        self.grid[cell.y][cell.x] = cell_type;
    }


    fn get_cell(&self, pos: &Pos) -> Cell {
        self.grid[pos.y][pos.x].clone()
    }


    fn apply_dir(&self, cell: &Pos, dir: &Direction) -> Option<Pos> {
        let new_y = cell.y as isize + dir.y;
        let new_x = cell.x as isize + dir.x;

        if new_y < 0 || new_x < 0 {
            return None;
        }

        let new_cell = Pos { y: new_y as usize, x: new_x as usize };
        match self.get_cell_state(&new_cell) {
            CellState::Free => return Some(new_cell),
            // CellState::Used{cell: Cell::Room} => return Some(new_cell),
            _ => return None
        }
    }


    fn get_cell_state(&self, cell: &Pos) -> CellState {
        if cell.y >= self.height || cell.x >= self.width {
            return CellState::OutOfGrid;
        } else {
            if let Cell::Wall = self.grid[cell.y][cell.x] {
                return CellState::Free;
            } else {
                return CellState::Used{cell: self.grid[cell.y][cell.x].clone()};
            }
        }
    }


    fn get_poss_cells(&self, cell: &Pos) -> Vec<PossCell> {
        let mut cells: Vec<PossCell> = vec![];
        for dir in Direction::all() {
            let bridge = self.apply_dir(&cell, &dir);
            if bridge.is_some() {
                let bridge = bridge.unwrap();
                let room = self.apply_dir(&bridge, &dir);
                if room.is_some() {
                    let room = room.unwrap();
                    cells.push(PossCell{ bridge, room });
                }
            }
        }
        cells
    }


    fn generate_labyrinth(&mut self) {
        let mut curr_cell = self.s_cell.clone();
        self.change_cell(&curr_cell, Cell::Start);
        let mut priority_cells: Vec<Pos> = vec![];

        // TODO: REMAKE ALGORYTHM
        for _i in 0..20 {
            let mut poss_cells = self.get_poss_cells(&curr_cell);
            if poss_cells.is_empty() {
                let indx: usize = 0; 
                // let indx = rand::rng().random_range(0..priority_cells.len());
                curr_cell = priority_cells[indx].clone();
                continue;
            }
            poss_cells.shuffle(&mut rand::rng());
            let way_lenght = rand::rng().random_range(0..5);
            for _i in 0..way_lenght {
                // let indx = rand::rng().random_range(0..poss_cells.len());
                let poss_cell = poss_cells[0].clone();
                self.change_cell(&poss_cell.bridge, Cell::Bridge);
                self.change_cell(&poss_cell.room, Cell::Room);
                curr_cell = poss_cell.room.clone();
                priority_cells.push(curr_cell.clone());
            }
        }
    }
}

