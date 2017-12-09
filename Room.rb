require_relative "Ant"

class Room
	attr_accessor :type, :anthill, :symbol
	def initialize(anthill,type)
		@anthill = anthill
		@type = type
	end

	#Spawn an ant based on the room type
	def spawnAnt
		ant = Ant.new(@anthill)
		case @type
		when "builder"
			class << ant
				def setAnt
					@ant_type = "builder"
				end
				def execute(room_type)
					anthill.food -= 1 #builder ant consumes 1 piece of food to create a new room
					room = Room.new(@anthill, room_type) #creates a room based on the room_type (determined by the anthill strategy)
					@alive = false #dies after the room is created
					@anthill.builders_count -= 1
					room
				end
			end
			ant.setAnt
		when "warrior"
			class << ant
				def setAnt
					@ant_type = "warrior"
					@symbol = "^".colorize(:background => @anthill.color)
				end
				def execute(cell)
					if(cell.hill == nil)
						if(cell.ants.length > 0)
							cell.ants.each{|ant|
								if(ant.anthill != self.anthill && ant.alive == true)
									if(ant.ant_type == "warrior")
										#If the warrior kills the other warrior, it gains +2 xp, otherwise the other ant gains xp
										result = interactWarrior(ant)
										if(result == 1)
											ant.alive = false
											cell.ants.delete(ant)
											ant.anthill.warriors_count -= 1
											@xp += 2
										elsif(result == 2)
											self.alive = false
											cell.ants.delete(self)
											@anthill.warriors_count -= 1
											ant.xp += 2
										end
									end
									#If the warrior kills the forager, it gains +1 xp, otherwise the forager gains xp
									if(ant.ant_type == "forager")
										result = interactForager(ant)
										if(result == 1)
											ant.alive = false
											cell.ants.delete(ant)
											ant.anthill.foragers_count -= 1
											@xp += 1
										elsif
											ant.xp += 1
										end
									end
								end
							}
						end
					#If the warrior destroys an anthill, it gets the food and color(not as main color) of it
					elsif(cell.hill != @anthill)
						result = interactAnthill(cell)
						if(result == 1)
							@symbol = "^".colorize(:color => cell.hill.color,:background => @anthill.color).underline
							@anthill.food += cell.hill.food
							cell.hill.isAlive = false
							cell.hill = nil
							@xp += 5
						else
							self.alive = false
							cell.ants.delete(self)
							@anthill.warriors_count -= 1
						end
					end
				end
				def interactWarrior(warrior)
					hit1 = rand(self.xp * self.xp)
					hit2 = rand(warrior.xp * warrior.xp)
					#The warrior with the greatest hit wins
					if (hit1 > hit2)
						return 1
					elsif (hit2 > hit1)
						return 2
					else
						return 0
					end
				end

				def interactForager(forager)
					chance = rand(2)
					#The forager has 50% chance of living
					if (chance == 1)
						return 1
					end
					return 0
				end

				def interactAnthill(cell)
					anthill = cell.hill
					hit = rand(5)
					#The warrior has 20% chance of destroying the anthill
					if (hit == 4)
						return 1
					end
					return 0
				end
			end
			ant.setAnt
		when "forager"
			class << ant
				def setAnt
					@ant_type = "forager"
					@symbol = "~".colorize(:background => @anthill.color)
				end
				def execute(cell)
					if(cell.ants.length > 0)
						cell.ants.each{|ant|
							if(ant.anthill != self.anthill && ant.alive == true)
								if(ant.ant_type == "warrior")
									#If forager escapes the warrior, it gains +1 xp, otherwise it dies
									result = interactWarrior(ant)
									if(result == 1)
										@xp += 1
									elsif(result == 2)
										self.alive = false
										cell.ants.delete(self)
										@anthill.foragers_count -= 1
										ant.xp += 1
									end
								end
							end
						}
						#If the forager manages to collect 2 or more foods, each food it collects will be counted double
						if(cell.food == 1)
							if(@xp >= 2)
								@anthill.food += 2
							else
								@anthill.food += 1
							end
							cell.food = 0
						end
					end
				end
				def interactWarrior(warrior)
					chance = rand(2)
					#The forager has 50% chance of living
					if (chance == 1)
						return 1
					end
					return 0
				end
			end
			ant.setAnt
		end
		ant
	end
end