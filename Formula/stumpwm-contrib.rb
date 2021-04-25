class StumpwmContrib < Formula
  desc "Extension Modules for StumpWM."
  homepage "https://github.com/stumpwm/stumpwm-contrib"
  url "https://github.com/stumpwm/stumpwm-contrib/archive/1dd7729e6405db9b35727e08d0da370e4ddac5dd.zip"
  version "2021-04-25"
  sha256 "569923d5704044c3478d084b3512071409f99afffd7fb21b2aa8f37e2a8f4bb0"
  license any_of: ["ISC", "GPLv3", "BSD-2-Clause"]
  head "https://github.com/stumpwm/stumpwm-contrib.git"

  def install
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
