# -*- encoding: utf-8 -*-
require 'working/gemspec'

keys_bound = File.readlines('README.rdoc').grep(/^\[\+\S+\+\]/).join "\n"

Working.gemspec(
  name: 'pry-fkeys',
  summary: Working.third_line_of_readme,
  description: (Working.third_line_of_readme + "\n\n" + keys_bound),
  version: PryFkeys::VERSION,
  authors: %w(☈king),
  email: 'pry-fkeys@sharpsaw.org',
  github: 'rking/pry-fkeys',
  deps: %w(pry),
)
