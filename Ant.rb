class Ant
	attr_accessor :ant_type, :position, :symbol, :anthill, :xp, :alive

	def initialize(anthill)
		#Anthill that ant belongs to
		@anthill = anthill

		#Initial position of an ant is its anthill's position
		@position = anthill.position

		#Type of an ant
		@ant_type = ""

		#Symbol of ant
		@symbol = ""

		#Status of an ant
		@alive = true

		#Experience of an ant
		@xp = 0
	end
	def execute
		#will be overriden in Object Runtime Modification
	end

	def setType
		#will be overriden in Object Runtime Modification
	end

	def setSymbol
		#will be overriden in Object Runtime Modification
	end

	def move
		if(@position != nil)
			if(@ant_type != "builder")
				possible_moves = []
				#If the ant is not on the right border, it can move right
				if(@position % 15 != 14)
					possible_moves << 'r'
				end
				#If the ant is not on the left border, it can move left
				if(@position % 15 != 0)
					possible_moves << 'l'
				end
				#If the ant is not on the last row, it can move down
				if(@position + 15 <= 224)
					possible_moves << 'd'
				end
				#If the ant is not on the first row, it can move up
				if(@position - 15 >= 1)
					possible_moves << 'u'
				end
				move_to = possible_moves[rand(possible_moves.length)]
				case (move_to)
				when 'r'
					@position += 1
				when 'l'
					@position -= 1
				when 'u'
					@position -= 15
				when 'd'
					@position += 15
				end
			end
		end
	end
end