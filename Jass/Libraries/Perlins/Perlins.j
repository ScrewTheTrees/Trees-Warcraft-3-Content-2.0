//Perlins noise generator, by ScrewTheTrees
//
library Perlins
	
	globals
		private real array NoiseGrad
		private integer array NoisePermMod12
		private integer array NoisePerm
		
		private real NoiseTerrainOffset
	endglobals

	//UTILITY MATH
	private function DOT takes integer gradIndex,real x,real y returns real
		return NoiseGrad[gradIndex] * x + NoiseGrad[gradIndex + 16000] * y
	endfunction
	private function Clamp takes real min,real max,real value returns real
		if ( value < min ) then
			set value=min
		elseif ( value > max ) then
			set value=max
		endif
		return value
	endfunction
	private function Floor takes real x returns integer
		local integer y= R2I(x)
		if ( y > x ) then
			set y=y - 1
		endif
		return y
	endfunction

	//NOISE
	private function IsXLargerYInt takes real x,real y returns integer
		if ( x > y ) then
			return 1
		endif
		return 0
	endfunction
	private function IsNotXLargerYInt takes real x,real y returns integer
		if ( x <= y ) then
			return 1
		endif
		return 0
	endfunction
	
	public function NoiseGetPointValue takes integer ID, integer Vertices, real xin, real yin returns real
		local real G2= 0.2113
		local real s= ( xin + yin ) * 0.3660
		local integer i= Floor(xin + s)
		local integer j= Floor(yin + s)
		local real t= ( i + j ) * G2
		local real x0= xin - ( i - t )
		local real y0= yin - ( j - t )
		local integer i1= IsXLargerYInt(x0 , y0)
		local integer j1= IsNotXLargerYInt(x0 , y0)
		local real x1= x0 - i1 + G2
		local real y1= y0 - j1 + G2
		local real x2= x0 - 1.0 + 2.0 * G2
		local real y2= y0 - 1.0 + 2.0 * G2
		local integer ii= ModuloInteger(i, Vertices)
		local integer jj= ModuloInteger(j, Vertices)
		local integer gi0= NoisePermMod12[ii + NoisePerm[jj + ID] + ID]
		local integer gi1= NoisePermMod12[ii + i1 + NoisePerm[jj + j1 + ID] + ID]
		local integer gi2= NoisePermMod12[ii + 1 + NoisePerm[jj + 1 + ID] + ID]
		local real t0= 0.5 - ( x0 * x0 ) - ( y0 * y0 )
		local real t1= 0.5 - ( x1 * x1 ) - ( y1 * y1 )
		local real t2= 0.5 - ( x2 * x2 ) - ( y2 * y2 )
		local real n0
		local real n1
		local real n2
		if ( t0 < 0 ) then
			set n0=0
		else
			set t0=t0 * t0
			set n0=t0 * t0 * DOT(gi0 , x0 , y0)
		endif
		if ( t1 < 0 ) then
			set n1=0
		else
			set t1=t1 * t1
			set n1=t1 * t1 * DOT(gi1 , x1 , y1)
		endif
		if ( t2 < 0 ) then
			set n2=0
		else
			set t2=t2 * t2
			set n2=t2 * t2 * DOT(gi2 , x2 , y2)
		endif
		
		return ( 70.0 * ( n0 + n1 + n2 ) ) //-1   1
	endfunction
	
	public function NoiseGetPointValueOctave takes integer ID, integer Vertices, real x, real y, integer octaves, real persistence returns real
		local real total = 0
		local real frequency = 0
		local real amplitude = 0
		local real maxValue = 0
		local integer i = 0
		
		loop
			exitwhen (i >= octaves)
			set total = total + NoiseGetPointValue(ID, Vertices, x * frequency, y * frequency) * amplitude
				
			set maxValue = maxValue + amplitude
			set amplitude = amplitude * persistence
			set frequency = frequency * 2
			set i = i + 1
		endloop
		
		return total / maxValue
	endfunction
	
	public struct Noise
		private integer ID
		private integer vertices
		
		static method create takes integer vertices returns Noise
			local Noise noice = Noise.allocate()
			set noice.vertices = vertices
			return noice
		endmethod
		
		public method GetPointValue takes real xin, real yin returns real
			return NoiseGetPointValue(ID, vertices, xin, yin)
		endmethod
		
		public method GetPointValueOctave takes real xin, real yin, integer octaves, integer persistence returns real
			return NoiseGetPointValueOctave(ID, vertices, xin, yin, octaves, persistence)
		endmethod
	endstruct
	
	//INIT FUNCTIONALITY
	public function CreateNoiseGrad takes integer index,real x,real y returns nothing
		set NoiseGrad[index]=x
		set NoiseGrad[index + 16000]=y
	endfunction	

	public function GeneratePerm takes integer Vertices returns integer
		local integer i= NoiseTerrainOffset
		local integer temp
		loop
			exitwhen ( i >= NoiseTerrainOffset + Vertices )
			set temp=GetRandomInt(0, 255)
			set NoisePerm[i]=temp
			set NoisePerm[i + Vertices]=temp
			set NoisePermMod12[i]=ModuloInteger(temp, 12)
			set NoisePermMod12[i + Vertices]=ModuloInteger(temp, 12)

			set i=i + 1
		endloop
		set temp=NoiseTerrainOffset
		set NoiseTerrainOffset=NoiseTerrainOffset + ( Vertices * 2 )
		return temp
	endfunction
endlibrary