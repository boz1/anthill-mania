require_relative('Anthill')

class Queen
	def initialize
		@anthill = ""
	end

	#Configures an anthill
	def addAnthill(position,strategy,color)
		@anthill = Anthill.new
		@anthill.setPosition(position).setStrategy(strategy).setColor(color).setInitialStatus
		self
	end

	#If anthill is instantiated it, returns the anthill
	def build
		if(@anthill != "")
			@anthill
		end
	end
end