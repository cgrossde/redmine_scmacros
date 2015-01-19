# ScmacrosRepositoryInclude
# Copyright (C) 2010 Gregory Romé
# Copyright (C) 2015 Christoph Gross
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
require 'redmine'

module ScmacrosRepositoryInclude
  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository.\n\n" +
      " \{{repo_include(file_path)}}\n" +
      " \{{repo_include(file_path, rev)}}\n"
    macro :repo_include do |obj, args|

      return nil if args.length < 1
      file_path = args[0].strip
      rev ||= args[1].strip if args.length > 1

      repo = @project.repository
      return nil unless repo

      text = repo.cat(file_path, rev)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)

      o = text

      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository.\n\n" +
      " \{{repo_includewiki(file_path)}}\n"
    macro :repo_includewiki do |obj, args|

      return nil if args.length < 1
      file_path = args[0].strip

      repo = @project.repository
      return nil unless repo

      text = repo.cat(file_path)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)

      o = textilizable(text)

      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes BDD feature file from 'develop' branch.\n\n" +
      " \{{feature(feature_name)}}\n"
    macro :feature do |obj, args|
      # Check for arg
      return nil if args.length < 1
      feature_name = args[0].strip
      # Get Repo
      repo = @project.repository
      return nil unless repo
      # Get develop branch
      branches = repo.branches
      return nil if branches.nil?
      develop_branch = branches.select{|x| x.to_s == 'develop'}
      develop_branch = develop_branch.first
      # Get rev of develop branch
      rev = develop_branch.revision
      # Build path
      path = "features/#{feature_name}.feature"

      # Get file with develop revision
      text = repo.cat(path, rev)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)

      # Highlight Feature, Scenario
      text = text.gsub(/(Feature:|Scenario:)/, '<span class="integer"><b>\1</b></span>');
      # Highlight When, Given, Then, And
      text = text.gsub(/(When|Given|Then|And)/, '<span class="comment">\1</span>');

      o = "<pre><code class=\"PHP syntaxhl\">#{text}</code></pre>"

      return o.html_safe
    end
  end
end
