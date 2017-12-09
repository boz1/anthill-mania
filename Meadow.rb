require_relative('Queen')
require_relative('Anthill')
require 'singleton'
require 'colorize'

class Meadow
	#Uses 'Singleton' module in order to implement the Singleton pattern
	include Singleton
	attr_accessor :size, :cells, :num_of_anthills, :anthills, :cells, :strategies
	def initialize()
		#Array to hold cells, used when displaying the meadow
		@cells = []

		#Anthills in the meadow
		@anthills = []

		#Max cell size
		@max_cell_size = 9

		#Strategies
		@strategies = []
	end

	#Sets the size of the grid
	def setSize(size)
		@size = size
		getStrategies
		createCells
	end

	#Sets the number of anthills that will be created
	def setNumberOfAnthills(num_of_anthills)
		@num_of_anthills = num_of_anthills
	end

	#Instaniate #size cells
	def createCells
		for i in 1..@size*@size
			@cells << Cell.new(i)
		end
		callBuilderQueen
	end

	def callBuilderQueen
		queen = Queen.new
		for i in 0...@num_of_anthills
			#String.colors[(i*2 + 2) % 16] gets the next color from the color array which has 16 different colors in it
			@anthills << queen.addAnthill(setAnthillPosition, @strategies[i], String.colors[(i*2 + 4) % 16]).build
		end
		updateCellsWithAnthill
	end

	#Returns an array of dynamically built strategies
	def getStrategies
		chances_of_forager = 0
		chances_of_warrior = 0
		chances_of_builder = 0

		for i in 0...@num_of_anthills
			strategy = []

			case rand(4)
			when 0 #Greedy
				chances_of_forager = 50
				chances_of_warrior = 25
				chances_of_builder = 25
			when 1 #Aggresive
				chances_of_forager = 25
				chances_of_warrior = 50
				chances_of_builder = 25
			when 2 #Constructive
				chances_of_forager = 25
				chances_of_warrior = 25
				chances_of_builder = 50
			when 3 #Balanced
				chances_of_forager = 34
				chances_of_warrior = 33
				chances_of_builder = 33
			end

			for i in 0...@size
				type1 = rand(chances_of_builder)
				type2 = rand(chances_of_warrior)
				type3 = rand(chances_of_forager)
				types = []
				types << type1
				types << type2
				types << type3
				max = type1
				max_index = 0
				for i in 0...types.length
					if(max <= types[i])
						max = types[i]
						max_index = i
					end
				end
				case max_index
				when 0
					strategy << "builder"
				when 1
					strategy << "warrior"
				when 2
					strategy << "forager"
				end
			end
			@strategies << strategy
		end
	end

	#Generate a random, empty position for a new anthill
	def setAnthillPosition
		position = rand(@cells.length)
		if(@cells[position].hill != nil)
			setAnthillPosition
		else
			#If the position is not already assigned to an anthill,
			#Assign it to the current anthill by putting a placeholder until the anthill object is created
			@cells[position].hill = "new anthill"
			position
		end
	end

	#Update each cell which contains an anthill
	def updateCellsWithAnthill
		@anthills.each {|anthill|
			@cells[anthill.position].hill = anthill
		}
	end

	#Spawn food at the start of each round
	def spawnFood
		food_location = rand(@cells.length)
		if(@cells[food_location].ants.length == 0 && @cells[food_location].food == 0 && @cells[food_location].hill == nil)
			@cells[food_location].food = 1
		end
	end

	#Display the menu according to the game status
	def displayMeadow
		system 'clear'
		for i in 0...@size
			print "__________".colorize(:color => :black,:background => :white)
		end
		print " ".colorize(:color => :black,:background => :white)
		puts
		cell_index = 0
		for i in 0...@size
			for j in 0...@size
				print "|".colorize(:color => :black,:background => :white)
				ant_length = 0
				if(@cells[cell_index].ants.length > 0)
					@cells[cell_index].ants.each{|ant|
						if(ant.alive && ant.ant_type != "builder" && ant.anthill.isAlive)
							ant_length += 1
						end
					}
				end
				if(@cells[cell_index].hill != nil)
					firstHalfSize = (@max_cell_size - ant_length)/2
					for k in 0...firstHalfSize
						print " ".colorize(:color => :black,:background => :white)
					end

					print "#".colorize(:background => @cells[cell_index].hill.color)
					firstHalfSize += 1

					if(@cells[cell_index].ants.length > 0)
						@cells[cell_index].ants.each{|ant|
							if(ant.alive && ant.ant_type != "builder" && ant.anthill.isAlive)
								print ant.symbol
								firstHalfSize += 1
							end
						}
					end
				else
					firstHalfSize = (@max_cell_size - ant_length)/2
					for k in 0...firstHalfSize
						if(k == 1 && @cells[cell_index].food == 1)
							print "*".colorize(:color => :white,:background => :red)
						else
							print " ".colorize(:color => :black,:background => :white)
						end
					end
					if(@cells[cell_index].ants.length > 0)
						@cells[cell_index].ants.each{|ant|
							if(ant.alive && ant.ant_type != "builder" && ant.anthill.isAlive)
								print ant.symbol
								firstHalfSize += 1
							end
						}
					end
				end
				secondHalfSize = @max_cell_size - firstHalfSize
				for k in 0...secondHalfSize
					print " ".colorize(:color => :black,:background => :white)
				end
				cell_index += 1
			end
			puts "|".colorize(:color => :black,:background => :white)
			for k in 0...@size
				print "__________".colorize(:color => :black,:background => :white)
			end
			print "_".colorize(:color => :black,:background => :white)
			puts
		end
		@anthills.each{|anthill|
			if(anthill.isAlive)
				puts "Anthill #{anthill}: Food = #{anthill.food} || Rooms = #{anthill.rooms.length} || Warriors = #{anthill.warriors_count} || Foragers = #{anthill.foragers_count} || Builders = #{anthill.builders_count}".colorize(:background => anthill.color, :color => :white)
			end
		}
	end

	#While there are multiple anthills still alive
	#isCompleted will be false
	def isComplete?
		num_of_alive_anthills = 0
		@anthills.each{|anthill|
			if(anthill.isAlive)
				num_of_alive_anthills += 1
			end
		}
		if(num_of_alive_anthills <= 1)
			return true
		end
		return false
	end

	def nextAnthill
		@anthills.each {|anthill|
			if(anthill.isAlive)
				spawnFood
				nextTurn(anthill)
			end
		}
	end

	def nextTurn(anthill)
		if(anthill.foragers_count > 0)
			anthill.ants.each { |ant|
				if(ant.alive)
					if(ant.ant_type == "builder")
						if(anthill.isEnoughFood? && (anthill.getTotalNumberOfAnts < @size)) #If there is enough food, builder builds a new room
							anthill.rooms << ant.execute(anthill.strategy[anthill.next_strategy])
							#If strategy index is exceeded go back to the start
							if(anthill.next_strategy < anthill.strategy.length - 1)
								anthill.next_strategy += 1
							else
								anthill.next_strategy = 0
							end
						end
					elsif (ant.ant_type == "forager")
						previous_position = ant.position
						@cells[previous_position].ants.delete(ant)
						ant.move
						@cells[ant.position].ants << ant
						ant.execute(@cells[ant.position])
					else
						previous_position = ant.position
						@cells[previous_position].ants.delete(ant)
						ant.move
						@cells[ant.position].ants << ant
						ant.execute(@cells[ant.position])
					end
				end
			}
			anthill.callRooms(@cells)
		else
			if(anthill.isAlive == true)
				anthill.isAlive = false
				@cells[anthill.position].hill = nil
			end
		end
	end

	def displayWinner
		@anthills.each{|anthill|
			if(anthill.isAlive)
				system 'clear'
				for i in 0...@size
					print "__________".colorize(:color => :black,:background => :white)
				end
				print " ".colorize(:color => :black,:background => :white)
				puts
				cell_index = 0
				for i in 0...@size
					for j in 0...@size
						print "|".colorize(:color => :black,:background => :white)
						for k in 0...@max_cell_size
							print " ".colorize(:color => :black,:background => anthill.color)
						end
					end
					puts "|".colorize(:color => :black,:background => :white)
					for k in 0...@size
						print "__________".colorize(:color => :black,:background => :white)
					end
					print "_".colorize(:color => :black,:background => :white)
					puts
				end
			end
		}
	end

end

class Cell
	attr_accessor :hill, :food, :ants
	def initialize(position)
		@position = position
		@hill = nil
		@food = 0 #A cell can only contain one food per turn
		@ants = []
	end
end