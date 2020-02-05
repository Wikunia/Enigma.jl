using Enigma
using Test

@testset "Enigma.jl" begin
    for rp1 = 1:26, rp2=1:26
        enigma = EnigmaMachine()
        set_rotors!(enigma, 1,2,3)
        set_rotor_positions!(enigma, rp1,rp2,4)
        set_ukw!(enigma, 2)

        message = "This is an Enigma test"
        encoded = encode(enigma, message)
        
        # set rotor position again for decoding
        set_rotor_positions!(enigma, rp1,rp2,4)
        decoded = decode(enigma, encoded)
        @test decoded == uppercase(replace(message, r"[^a-zA-Z]"=>""))
    end
end
