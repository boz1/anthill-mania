require_relative("Room")

class Anthill
	attr_accessor :color, :position, :strategy, :food, :rooms, :warriors_count, :foragers_count, :builders_count, :ants, :isAlive, :next_strategy
	def initialize
		#Counts of each ant type
		@foragers_count = 0
		@warriors_count = 0
		@builders_count = 0

		#Ants of an anthill
		@ants = []

		#Initial food of an anthill
		@food = 5

		#Rooms of the anthill, at start it has a room for each type of ant
		@rooms = [Room.new(self, "forager"), Room.new(self, "warrior") ,  Room.new(self, "builder")]

		#Status of the anthill
		@isAlive = true

		#Index of next room type to be build based on the strategy array
		@next_strategy = 0
	end

	#Starting status of an anthill
	def setInitialStatus
		@rooms.each{|room|
			ant = room.spawnAnt
			@ants << ant
			case ant.ant_type
			when 'forager'
				@foragers_count += 1
			when 'warrior'
				@warriors_count += 1
			when 'builder'
				@builders_count += 1
			end
		}
	end

	def setColor(color)
		@color = color
		self
	end

	def setPosition(position)
		@position = position
		self
	end

	def setStrategy(strategy)
		@strategy = strategy
		self
	end

	#Calls a room of an anthill
	def callRooms(cells)
		@rooms.each{|room|
			if(isEnoughFood? && (getTotalNumberOfAnts < 15))
				ant = room.spawnAnt
				@food -= 1
				@ants << ant
				if(ant.ant_type == "builder")
					if(self.isEnoughFood?) #If there is enough food, builder builds a new room
						self.rooms << ant.execute(self.strategy[self.next_strategy])
						#If strategy index is exceeded go back to the start
						if(self.next_strategy < self.strategy.length - 1)
							self.next_strategy += 1
						else
							self.next_strategy = 0
						end
					end
				elsif (ant.ant_type == "forager")
					previous_position = ant.position
					cells[previous_position].ants.delete(ant)
					ant.move
					cells[ant.position].ants << ant
					ant.execute(cells[ant.position])
				else
					previous_position = ant.position
					cells[previous_position].ants.delete(ant)
					ant.move
					cells[ant.position].ants << ant
					ant.execute(cells[ant.position])
				end
				case ant.ant_type
				when 'forager'
					@foragers_count += 1
				when 'warrior'
					@warriors_count += 1
				when 'builder'
					@builders_count += 1
				end
			end
		}
	end

	def isEnoughFood?
		@food > 0
	end

	def getTotalNumberOfAnts
		@builders_count + @foragers_count + @warriors_count
	end
end