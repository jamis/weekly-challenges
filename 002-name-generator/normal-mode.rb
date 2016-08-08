# name = [ prefix ], syllable, { syllable }, [ final ]
#
# prefix = syllable, ( ' ' | '-' )
#
# syllable = 'ab' | 'ael' | 'al' | 'am' | 'ar' | 'arg' |
#            'bal' | 'bar' | 'bel' | 'bor' |
#            'ca' | 'cal' | 'car' | 'cel' | 'cír' |
#            'dam' | 'dim' | 'dor' | 'dún' |
#            'ed' | 'eg' | 'el' | 'em' | 'en' | 'er' |
#            'fae' | 'fa' | 'far' | 'fin' | 'fir' |
#            'gal' | 'glam' | 'gol' |
#            'hal' | 'har' | 'hur' |
#            'ia' | 'im' | 'in' |
#            'la' | 'lam' | 'lan' | 'lo' | 'lor' |
#            'ma' | 'mal' | 'men' | 'mer' | 'min' | 'mir' | 'mor' |
#            'nan' | 'nar' | 'nen' | 'ni' | 'no' | 'nur' |
#            'on' | 'or' | 'os' |
#            'par' | 'pel' | 'pin' |
#            'ra' | 'ram' | 'ri' | 'ro' |
#            'sa' | 'sir' |
#            'ta' | 'taur' | 'tin' | 'tol' | 'tor' |
#            'uil' | 'ul'
#
# final = 'ath' | 'ryn' | 'ond' | 'dhrim' | 'thil' | 'viel'

class SindarinNameGenerator
  def name
    s = (rand(4) < 1) ? _prefix : ""

    n = (s.length > 0) ? 1 : 0

    while n < 2 || (n < 5 && rand(10) < 5)
      s << _syllable
      n += 1
    end

    s << _final if rand(10) < 5 && n < 5

    s
  end

  def _prefix
    s = ""
    s << _syllable
    s << [ '-', ' ' ].sample
    s
  end

  def _final
    %w(ath ryn ond dhrim thil dir viel).sample
  end

  def _syllable
    %w( ab ael al am ar arg
        bal bar bel bor
        ca cal car cel cír
        dam dim dor dún
        ed eg el em en er
        fae fa far fin fir
        gal glam gol
        hal har hur
        ia im in
        la lam lan lo lor
        ma mal men mer min mir mor
        nan nar nen ni no nur
        on or os
        par pel pin
        ra ram ri ro
        sa sir
        ta taur tin tol tor
        uil ul ).sample
  end
end

gen = SindarinNameGenerator.new
10.times do |n|
  puts "%2d. %s" % [n+1, gen.name]
end
