class Game

  def initialize(num_rows, num_columns, num_bombs)

    @board = Board.new(num_rows, num_columns, num_bombs)
    @quit = false

  end

  def play()

    until @board.is_finished || @quit do

      @board.render(false)

      puts "------------------------------------------------"
      puts "Enter a click (from top-left, row column e.g. 5 3)"
      puts "'q' to quit..."
      puts "------------------------------------------------"

      process_input(gets.chomp)

    end

  end

  def process_input(input)

    if input == "q"

      puts "------------------------------------------------"
      puts "Of all the stratagems, to know when to quit is the best. -Proverb"

      @board.render(true)

      @quit = true

    else

      click_coor = input.split(' ')
      click_y_offset = click_coor[0].to_i
      click_x_offset = click_coor[1].to_i

      @board.process_click(click_y_offset - 1, click_x_offset - 1)

    end

  end

end

class Board

  def initialize(num_rows, num_columns, num_bombs)

    @bomb_clicked = false
    @num_rows = num_rows
    @num_columns = num_columns
    @num_bombs = num_bombs
    @bombs = Array.new
    @cells = Array.new(num_rows){Array.new(num_columns)}

    populate_bombs()

  end

  def populate_bombs()

    until @bombs.count == @num_bombs do

      y_offset = rand(@num_rows)
      x_offset = rand(@num_columns)

      #check for duplicates
      if !@bombs.any? {|b| b.y_offset == y_offset && b.x_offset == x_offset}
        @bombs.push(Bomb.new(y_offset, x_offset))
      end

    end

  end

  def render(reveal)

    puts "------------------------------------------------"

    for y in 0..(@num_rows - 1)

      for x in 0..(@num_columns - 1)

        cell_bomb = @bombs.select {|b| b.y_offset == y && b.x_offset == x}

        if reveal && cell_bomb.count > 0
          print cell_bomb.first.display
        elsif @cells[y][x].nil?
          print "\u2B1B "
        else
          print @cells[y][x]
        end

      end

      puts ""

    end

  end

  def process_click(click_y_offset, click_x_offset)

    clicked_bomb_index = @bombs.index {|b| b.y_offset == click_y_offset && b.x_offset == click_x_offset}

    if (clicked_bomb_index)
      @bombs[clicked_bomb_index].clicked = true
    else
      clear_cells(click_y_offset, click_x_offset)
    end

  end

  def clear_cells(y_offset, x_offset)

    if (!@cells[y_offset][x_offset].nil?)
      #cell already checked
      return
    end

    bomb_count_for_cell = get_num_bombs_for_cell(y_offset, x_offset)

    if (bomb_count_for_cell == 0)

      @cells[y_offset][x_offset] = "\u2b1c "

      for y in y_offset - 1..y_offset + 1
      for x in x_offset - 1..x_offset + 1

          if y >= 0 && y <= @num_rows - 1 && x >= 0 && x <= @num_columns - 1
            clear_cells(y,x)
          end

        end
      end

    else
      @cells[y_offset][x_offset] = " " + bomb_count_for_cell.to_s + " "
    end

  end

  def is_finished

    if @bombs.any? {|b| b.clicked}

    puts "------------------------------------------------"
      puts "Mistakes are the portals of discovery. -Joyce"

      render(true)

      return true

    elsif is_board_cleared

      puts "------------------------------------------------"
      puts "In a mind clear as still water,"
      puts "even the waves, breaking,"
      puts "are reflecting its light."
      puts "-Dogen"

      render(true)

      return true

    else
      return false
    end

  end

  def is_board_cleared

    for y in 0..(@num_rows - 1)
      for x in 0..(@num_columns - 1)

        if (@cells[y][x].nil? && !@bombs.any? {|b| b.y_offset == y && b.x_offset == x})
          return false
        end

      end
    end

    return true

  end

  def get_num_bombs_for_cell(cell_y_offset, cell_x_offset)
    @bombs.count{ |b| b.y_offset >= (cell_y_offset - 1) && b.y_offset <= (cell_y_offset + 1) && b.x_offset >= (cell_x_offset - 1) && b.x_offset <= (cell_x_offset + 1)}
  end

  end

class Bomb

  attr_accessor :y_offset, :x_offset, :clicked

  def initialize(y_offset, x_offset)

    @y_offset = y_offset
    @x_offset = x_offset
    @clicked = false

  end

  def display

    if (@clicked)
      return " \e[0;31m\u272A\e[0m "
    else
      return " \u272A "
    end

  end

end

game = Game.new(10, 10, 3)
game.play()
