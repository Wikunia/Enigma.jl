using Enigma
using Test

@testset "Basics" begin
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
        @test decoded == enigma_styled_text(message)
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
        @test decoded == enigma_styled_text(message)
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

@testset "https://piotte13.github.io/" begin
    enigma = EnigmaMachine()
    set_rotors!(enigma, 1,2,3)
    set_rotor_positions!(enigma, 1,1,1)
    set_ukw!(enigma, 2)

    message = "Test"
    encoded = encode(enigma, message)
    @test encoded == "OLPF"

    # =============================== #
    enigma = EnigmaMachine()
    set_rotors!(enigma, 1,2,3)
    set_rotor_positions!(enigma, 4,9,7)
    set_ukw!(enigma, 2)

    message = "TestTestTestTestTest"
    encoded = encode(enigma, message)
    @test encoded == "UKTCV GCKJF GOJFX POSOH"

    # =============================== #
    enigma = EnigmaMachine()
    set_rotors!(enigma, 3,4,2)
    set_rotor_positions!(enigma, 5,9,5)
    set_ukw!(enigma, 2)
    set_plugboard!(enigma, "TE SA")

    message = "The quick brown fox jumps over the lazy dog The quick brown fox jumps over the lazy dog"
    encoded = encode(enigma, message)
    @test encoded == "IYAAB ZZPON MPWRT RDKNG VEEHN FQJKD DLWGH JOAHE FPGCM JHGLA OBNJJ CRDJL OCIYW NUSHT"

    # =============================== SECRET MESSAGE ======================= #
    enigma = EnigmaMachine()
    set_rotors!(enigma, 1,2,3)
    set_rotor_positions!(enigma, 1,2,3)
    set_ukw!(enigma, 3)
    set_plugboard!(enigma, "DG XB JL")

    message = "BQGYP VBFTW XOMTP FBMVW NNUMF WDNVX ANCRD TBDZX ZGQGV OMGFB KUPHB ORKZU MSTHH PTMSH UXIDW FVUVJ"
    encoded = encode(enigma, message)
    @test encoded == "LHJRY PFESX YIPQV UCIRC QVYIV QYUUA KLRVN PQWQJ HOJNF QZBYM XYMOO NDONW IELFM ICEXZ FWBVO DSQFX"
end
end

@testset "plotting" begin
@testset "just let it run" begin
    # Just tests that the methods don't error :D
    enigma = EnigmaMachine()
    plts = get_enigma_decode_plots!(enigma, 'K')
    @test length(plts) == 29
    animate_plots(plts[1:2], "/tmp/enigma_plot"; end_extra=0)
end
end