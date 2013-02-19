# -*- encoding: utf-8 -*-
require 'working/gemspec'
$:.unshift 'lib'
require 'pry-fkeys'

Working.gemspec(
  :name => 'pry-fkeys',
  :summary => Working.third_line_of_readme,
  :description => Working.third_line_of_readme,
  :version => PryFkeys::VERSION,
  :authors => %w(☈king),
  :email => 'pry-fkeys@sharpsaw.org',
  :github => 'rking/pry-fkeys',
  :deps => %w(pry),
)
