class StumpwmContrib < Formula
  desc "Extension Modules for StumpWM."
  homepage "https://github.com/stumpwm/stumpwm-contrib"
  url "https://github.com/stumpwm/stumpwm-contrib/archive/1dd7729e6405db9b35727e08d0da370e4ddac5dd.zip"
  version "2021-04-25"
  sha256 "569923d5704044c3478d084b3512071409f99afffd7fb21b2aa8f37e2a8f4bb0"
  license any_of: ["ISC", "GPLv3", "BSD-2-Clause"]
  head "https://github.com/stumpwm/stumpwm-contrib.git"

  depends_on "z80oolong/stumpwm/stumpwm"
  depends_on "libfixposix"
  depends_on "sbcl" => :build

  resource("clx-truetype") do
    url "https://github.com/LispLima/clx-truetype.git"
  end

  def install
    resource("clx-truetype").stage do
      (Formula["z80oolong/stumpwm/stumpwm"].libexec/"quicklisp/local-projects").install "#{Pathname.pwd}" => "clx-truetype"
    end

    system "#{Formula["sbcl"].bin}/sbcl", "--load", "#{Formula["z80oolong/stumpwm/stumpwm"].libexec}/quicklisp/setup.lisp", \
      "--eval", %[(progn (ql:quickload "clx-truetype") (quit))]

    system "#{Formula["sbcl"].bin}/sbcl", "--load", "#{Formula["z80oolong/stumpwm/stumpwm"].libexec}/quicklisp/setup.lisp", \
      "--eval", %[(progn (ql:quickload "babel") (ql:quickload "dbus") (ql:quickload "cffi") (ql:quickload "usocket-server"))], \
      "--eval", %[(progn (ql:quickload "percent-encoding") (ql:quickload "xkeyboard") (ql:quickload "cl-fad") (ql:quickload "drakma"))], \
      "--eval", %[(progn (ql:quickload "zpng") (ql:quickload "uiop") (ql:quickload "quri") (ql:quickload "py-configparser"))], \
      "--eval", %[(progn (ql:quickload "clim") (ql:quickload "clim-lisp") (ql:quickload "mcclim") (ql:quickload "slim") (quit))]

    %w(media minor-mode modeline util).each do |d|
      (share/"stumpwm-contrib").install "#{buildpath}/#{d}"
    end

    lispcode = ";; Add loadpath of stumpwm-contrib library.\n\n"
    lispcode << "(progn "

    (share/"stumpwm-contrib").glob("*/*") do |d|
      lispcode << %[\n  (add-to-load-path "#{d}")]
    end
    lispcode << ")\n"

    (share/"stumpwm-contrib/setup.lisp").write(lispcode)
  end
end
