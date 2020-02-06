using Enigma
using Test

@testset "No plugboard" begin
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

@testset "Plugboard" begin
    alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
    for rp1 = 1:26, pb1 in [9,11,15], pb2 in [10,20,12], pb3 in [4,5,6], pb4 in [24,13]
        enigma = EnigmaMachine()
        set_rotors!(enigma, 1,2,3)
        set_rotor_positions!(enigma, rp1,9,10)
        set_ukw!(enigma, 2)
        setting = ""
        setting *= Char(pb1+64)
        setting *= Char(pb2+64)
        setting *= " "
        setting *= Char(pb3+64)
        setting *= Char(pb4+64)
        set_plugboard!(enigma, setting)

        message = "The quick brown fox jumps over the lazy dog"
        encoded = encode(enigma, message)
        
        # set rotor position again for decoding
        set_rotor_positions!(enigma, rp1,9,10)
        decoded = decode(enigma, encoded)
        @test decoded == uppercase(replace(message, r"[^a-zA-Z]"=>""))
    end
end

@testset "Plugboard ErrorException" begin
    enigma = EnigmaMachine()
    set_rotors!(enigma, 1,2,3)
    set_rotor_positions!(enigma, 3,9,10)
    set_ukw!(enigma, 2)
    setting = "AB AC"
    @test_throws ErrorException set_plugboard!(enigma, setting)

    enigma = EnigmaMachine()
    set_rotors!(enigma, 1,2,3)
    set_rotor_positions!(enigma, 3,9,10)
    set_ukw!(enigma, 2)
    setting = "AB CB"
    @test_throws ErrorException set_plugboard!(enigma, setting)
end