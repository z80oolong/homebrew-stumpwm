class Stumpwm < Formula
  desc "The Stump Window Manager"
  homepage "https://stumpwm.github.io/"
  url "https://github.com/stumpwm/stumpwm/archive/refs/tags/20.11.tar.gz"
  version "20.11"
  head "https://github.com/stumpwm/stumpwm.git"
  sha256 "8c9aaab9ad7cbc35e705c085e8661b20d88b84e750f7b1859e65a8b2f1ad562c"
  license "GPL-2.0"

  depends_on "sbcl" => :build

  resource("quicklisp") do
    url "https://beta.quicklisp.org/quicklisp.lisp"
    sha256 "4a7a5c2aebe0716417047854267397e24a44d0cce096127411e9ce9ccfeb2c17"
  end

  def install
    ENV["PATH"] = "#{libexec}/sbcl/bin:#{ENV["PATH"]}"
    (libexec/"sbcl/bin").mkpath

    system "cp", "-p", "#{Formula["sbcl"].bin}/sbcl", "#{libexec}/sbcl/bin/sbcl"
    system "chmod", "u+wx", "#{libexec}/sbcl/bin/sbcl"

    resource("quicklisp").stage do
      system "#{Formula["sbcl"].bin}/sbcl", \
        "--load", "./quicklisp.lisp", \
        "--eval", %{(progn (quicklisp-quickstart:install :path "#{libexec}/quicklisp") (quit))}
    
      inreplace "#{libexec}/sbcl/bin/sbcl", \
        /exec "[^"]*"/, %{exec "#{Formula["sbcl"].libexec}/bin/sbcl" --load #{libexec}/quicklisp/setup.lisp}
    end

    system "#{libexec}/sbcl/bin/sbcl", \
      "--eval", %{(progn (ql:quickload "clx") (ql:quickload "cl-ppcre") (ql:quickload "alexandria") (quit))}

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--with-lisp=sbcl"
    system "make"
    system "make", "install"

    (libexec/"sbcl").rmtree
  end

  test do
    system "#{bin}/stumpwm", "--version"
  end
end

