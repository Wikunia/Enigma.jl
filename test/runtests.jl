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

    for rp1 = 1:26, rp2=1:26
        enigma = EnigmaMachine()
        set_rotors!(enigma, 4,3,5)
        set_rotor_positions!(enigma, rp1,rp2,4)
        set_ukw!(enigma, 3)

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

@testset "Bombe" begin
@testset "Cracking given all but plugboard/hint pos" begin
    crack_message = "VZEKL OYDBD SFFYD LZQVS HAWVP BGAMY ATKPW T"
    hint = "message"
    bombe = BombeMachine(crack_message, hint)
    set_possible_rotors!(bombe, 1,2,3)
    set_possible_rotor_positions!(bombe, 1,1,1)
    set_possible_ukws!(bombe, 1:1)
    enigmas = run_cracking(bombe; log=false)
    found = false
    correct_message = enigma_styled_text("This is a test message for testing the Bombe")
    
    for enigma in enigmas
        encoded = encode(enigma, crack_message)
        if encoded == correct_message
            found = true
            break
        end
    end
    @test found === true

    # different rotors and positions 
    crack_message = "QRTUV RQMHR GTBJU NVXAN OPHTM BZAHZ YFKUL CRVRY MLTVW KRXIH EAWXJ "
    hint = "message"
    bombe = BombeMachine(crack_message, hint)
    set_possible_rotors!(bombe, 3,2,1)
    set_possible_rotor_positions!(bombe, 4,7,8)
    set_possible_ukws!(bombe, 1)
    enigmas = run_cracking(bombe; log=false)
    found = false
    correct_message = enigma_styled_text("A long long message with no real meaning but it is important to test")
    
    for enigma in enigmas
        encoded = encode(enigma, crack_message)
        if encoded == correct_message
            found = true
            break
        end
    end
    @test found === true

    
    # Try a larger set of possibilities
    crack_message = "HGHXI AGYEY NDIFW PRMDD QSMJG DCAKP FMIZL RVQIZ WRLJM "
    hint = "weatherreport"
    bombe = BombeMachine(crack_message, hint)
    set_possible_rotors!(bombe, 3,1:4,1:4)
    set_possible_rotor_positions!(bombe, 1:5,1:26,1:26)
    set_possible_ukws!(bombe, 1)
    set_possible_hint_positions!(bombe, 1:5)
    enigmas = run_cracking(bombe; log=false)
    found = false
    correct_message = enigma_styled_text("A Weatherreport It is very nice outside so be friendly")
    
    for enigma in enigmas
        encoded = encode(enigma, crack_message)
        if encoded == correct_message
            found = true
            break
        end
    end
    @test found === true

    # unknown ukw but rotor position
    crack_message = "BLCCX HTMVX NRYXV REFZO LVXQU YHWFJ KHZDU BYBYK RTGHI GRWH"
    hint = "secret message"
    bombe = BombeMachine(crack_message, hint)
    set_possible_rotors!(bombe, 3,4,1)
    set_possible_hint_positions!(bombe, 10:20)
    enigmas = run_cracking(bombe; log=false)
    found = false
    correct_message = enigma_styled_text("This is another secret message with different ukw setting")
    hint_part = uppercase(replace(hint, " "=>""))
    @test length(enigmas) >= 1

    for enigma in enigmas
        encoded = encode(enigma, crack_message)
        encoded_str = replace(encoded, " "=>"")
        @test findfirst(hint_part, encoded_str[10:40]) !== nothing
    end
end
end
@testset "plotting" begin
@testset "just let it run" begin
    # Just tests that the methods don't error :D
    enigma = EnigmaMachine()
    plts = get_enigma_decode_plots!(enigma, 'K')
    @test length(plts) == 29
    animate_plots(plts[1:2], "enigma_plot_320948209384023842204804038024"; end_extra=1)
    rm("enigma_plot_320948209384023842204804038024.gif")
end
end
