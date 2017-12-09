require_relative('Meadow')

class Engine
	def initialize(size, anthill_count)
		@size = size
		@anthill_count = anthill_count
	end
	def work
		Meadow.instance.setNumberOfAnthills(@anthill_count)
		Meadow.instance.setSize(@size)
		Meadow.instance.displayMeadow()
		while(!Meadow.instance.isComplete?) #Cycle until either one anthill or no anhtills are left
			system 'clear'
			Meadow.instance.nextAnthill() #Traverse anthills and send them to nextTurn method as parameter
			Meadow.instance.displayMeadow() #Displays the current status of the anthill
			Time.new
			sleep 0.5 #Sleep 0.5 before the next turn is executed
		end
		Meadow.instance.displayWinner #Display colors of the winner anthill, if there is any, all over the meadow
	end
end