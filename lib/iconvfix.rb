# Copyright (C) 2002-2004 Kouichirou Eto, All rights reserved.

 require "iconv"

 class Iconv
  def self.iconv_to_utf8(from, str)
    iconv = Iconv.new(from, "UTF-8")
    out = ""
    begin
      out << iconv.iconv(str)
    rescue Iconv::IllegalSequence => e
      out << e.success
      ch, str = e.failed.split(//u, 2)
      out << if respond_to?(:unknown_unicode_handler)
                      u = ch.unpack("U").first
                      unknown_unicode_handler(u)
                    else
                      "?"
                    end
      retry
    end
    out
  end

  def self.unknown_unicode_handler (u)
    sprintf("&#x%04x;", u)
  end

  def self.iconv_to_from(to, from, str)
    iconv = Iconv.new(to, from)
    out = ""
    begin
      out << iconv.iconv(str)
    rescue Iconv::IllegalSequence => e
      out << e.success
      ch, str = e.failed.split(//u, 2)
      out << "?"
      retry
    rescue Iconv::InvalidCharacter => e
      out << e.success
      ch, str = e.failed.split(//u, 2)
      out << "?"
      retry
    end
    out
  end
 end

 class String
   def euctou8()  Iconv.iconv_to_from("UTF-8", "EUC-JP", self)end
   def u8toeuc()  Iconv.iconv_to_from("EUC-JP", "UTF-8", self)end
   def sjistou8() Iconv.iconv_to_from("UTF-8", "Shift_JIS", self)end
   def u8tosjis() Iconv.iconv_to_from("Shift_JIS", "UTF-8", self)end
   def jistou8()  Iconv.iconv_to_from("UTF-8", "ISO-2022-JP", self)end

   def euctosjis()  Iconv.iconv_to_from("Shift_JIS", "EUC-JP", self)end

  def u8tojis()
    i = Iconv.new("ISO-2022-JP", "UTF-8")
    i.iconv(self)+i.close
  end

  def u8tou16
    Iconv.iconv_to_from("UTF-16", "UTF-8", self).sub(/\A\376\377/, "")
  end

  def u8tou32
    Iconv.iconv_to_from("UTF-32", "UTF-8", self).sub(/\A\0\0\376\377/, "")
  end

  def u32tou8
    Iconv.iconv_to_from("UTF-8", "UTF-32", self)
  end

  def u32tou16
    Iconv.iconv_to_from("UTF-16", "UTF-32", self).sub(/\A\376\377/, "")
  end

  def u16toeuc()Iconv.iconv_to_from("EUC-JP", "UTF-16", self)end
  def u16tosjis()Iconv.iconv_to_from("Shift_JIS", "UTF-16", self) end
 end
