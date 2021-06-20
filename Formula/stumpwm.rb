class Stumpwm < Formula
  desc "The Stump Window Manager"
  homepage "https://stumpwm.github.io/"
  url "https://github.com/stumpwm/stumpwm/archive/refs/tags/20.11.tar.gz"
  version "20.11"
  head "https://github.com/stumpwm/stumpwm.git"
  sha256 "8c9aaab9ad7cbc35e705c085e8661b20d88b84e750f7b1859e65a8b2f1ad562c"
  license "GPL-2.0"

  depends_on "sbcl" => :build
  depends_on "libfixposix"

  resource("quicklisp") do
    url "https://beta.quicklisp.org/quicklisp.lisp"
    sha256 "4a7a5c2aebe0716417047854267397e24a44d0cce096127411e9ce9ccfeb2c17"
  end

  resource("stumpwm-contrib") do
    url "https://github.com/stumpwm/stumpwm-contrib.git"
  end

  resource("clx-truetype") do
    url "https://github.com/LispLima/clx-truetype.git"
  end

  def install
    ENV["PATH"] = "#{buildpath}/.bin:#{ENV["PATH"]}"
    (buildpath/".bin").mkpath

    resource("quicklisp").stage do
      system "#{Formula["sbcl"].bin}/sbcl", \
        "--load", "./quicklisp.lisp", \
        "--eval", %{(progn (quicklisp-quickstart:install :path "#{libexec}/quicklisp") (quit))}

      wrappercode =  "#!/bin/bash\n"
      wrappercode << %[SBCL_SOURCE_ROOT="#{Formula["sbcl"].share}/sbcl/src" ]
      wrappercode << %[SBCL_HOME="#{Formula["sbcl"].lib}/sbcl" ]
      wrappercode << %[exec "#{Formula["sbcl"].libexec}/bin/sbcl" ]
      wrappercode << %[--load #{libexec}/quicklisp/setup.lisp "$@"\n]

      (buildpath/".bin/sbcl").write(wrappercode)
      system "chmod", "u+x", "#{buildpath}/.bin/sbcl"
    end

    system "#{buildpath}/.bin/sbcl", \
      "--eval", %[(progn (ql:quickload "clx") (ql:quickload "cl-ppcre") (ql:quickload "alexandria") (quit))]

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-lisp=sbcl"
    system "make"
    system "make", "install"

    resource("clx-truetype").stage do
      (libexec/"quicklisp/local-projects").install "#{Pathname.pwd}" => "clx-truetype"
    end

    system "#{buildpath}/.bin/sbcl", "--eval", %[(progn (ql:quickload "clx-truetype") (quit))]
    system "#{buildpath}/.bin/sbcl", \
      "--eval", %[(progn (ql:quickload "babel") (ql:quickload "dbus") (ql:quickload "cffi") (ql:quickload "usocket-server"))], \
      "--eval", %[(progn (ql:quickload "percent-encoding") (ql:quickload "xkeyboard") (ql:quickload "cl-fad") (ql:quickload "drakma"))], \
      "--eval", %[(progn (ql:quickload "zpng") (ql:quickload "uiop") (ql:quickload "quri") (ql:quickload "py-configparser"))], \
      "--eval", %[(progn (ql:quickload "clim") (ql:quickload "clim-lisp") (ql:quickload "mcclim") (ql:quickload "slim") (quit))]

    resource("stumpwm-contrib").stage do
      %w(media minor-mode modeline util).each do |d|
        (share/"stumpwm-contrib").install "#{Pathname.pwd}/#{d}"
      end

      lispcode =  ";; Add loadpath of stumpwm-contrib library.\n\n"
      lispcode << "(progn "
      lispcode << %[\n  (when (probe-file "#{libexec}/quicklisp/setup.lisp")]
      lispcode << %[\n    (load "#{libexec}/quicklisp/setup.lisp"))]
      (share/"stumpwm-contrib").glob("*/*") do |d|
        lispcode << %[\n  (add-to-load-path "#{d}")]
      end
      lispcode << ")\n"

      (share/"stumpwm-contrib/setup.lisp").write(lispcode)
      bin.install_symlink "#{share}/stumpwm-contrib/util/stumpish/stumpish"
    end
  end

  test do
    system "#{bin}/stumpwm", "--version"
  end
end
