# coding: utf-8
require 'i18n/tasks/reports/base'
require 'terminal-table'
module I18n
  module Tasks
    module Reports
      class Terminal < Base
        include Term::ANSIColor

        def missing_translations(keys = task.missing_keys)
          keys.sort_by_attr!(locale: :asc, type: :desc, key: :asc)
          print_title missing_title(keys)
          if keys.present?

            $stderr.puts "#{bold 'Types:'} #{missing_types.values.map { |t| "#{t[:glyph]} #{t[:summary]}" } * ', '}"

            print_table headings: [magenta(bold('Locale')), bold('Type'), magenta('i18n Key'), bold(cyan "Base value (#{base_locale})")] do |t|
              t.rows = keys.map { |key|
                glyph = missing_types[key.type][:glyph]
                glyph = {missing_from_base: red(glyph), missing_from_locale: yellow(glyph), eq_base: bold(blue(glyph))}[key.type]
                if key[:type] == :missing_from_base
                  locale     = magenta bold key.locale
                  base_value = ''
                else
                  locale     = magenta key.locale
                  base_value = task.t(key.key).to_s.strip
                end
                [{value: locale, alignment: :center},
                 {value: glyph, alignment: :center},
                 magenta(key[:key]),
                 base_value]
              }
            end
          else
            print_success 'Good job! No translations missing!'
          end
        end

        def unused_translations(keys = task.unused_keys)
          print_title unused_title(keys)
          if keys.present?
            print_table headings: [bold(magenta('i18n Key')), cyan("Base value (#{base_locale})")] do |t|
              t.rows = keys.map { |k| [magenta(k.key), cyan(k.value)] }
            end
          else
            print_success 'Good job! Every translation is used!'
          end
        end

        private

        def print_title(title)
          $stderr.puts "#{bold cyan title.strip} #{dark "|"} #{bold "i18n-tasks v#{I18n::Tasks::VERSION}"}"
        end

        def print_success(message)
          $stderr.puts(bold green message)
        end

        private
        def indent(txt, n = 2)
          spaces = ' ' * n
          txt.gsub /^/, spaces
        end

        def print_table(opts, &block)
          puts ::Terminal::Table.new(opts, &block)
        end
      end
    end
  end
end
