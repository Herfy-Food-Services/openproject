# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
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
#
# See COPYRIGHT and LICENSE files for more details.
#++

require "rails_helper"
require_relative "shared_work_package_table_examples"

RSpec.describe Backlogs::SprintReports::Widgets::AddedTable,
               type: :component,
               with_ee: %i[baseline_comparison sprint_report_pro_widgets] do
  include_examples "sprint report work package table widget" do
    let(:widget_name) { "Sprint scope increase" }
    let(:added_after_start_ids) { [12, 13] }
    let(:breakdown_overrides) do
      { added_after_start_ids: }
    end
  end

  context "with all permissions and entitlements" do
    let(:filters) do
      [
        { sprintId: { operator: "=", values: [sprint.id.to_s] } },
        { id: { operator: "=", values: %w[12 13] } }
      ]
    end

    context "when the sprint has no dates set" do
      let(:start_date) { nil }
      let(:finish_date) { nil }

      include_examples "renders a blankslate" do
        let(:description) { "Sprint start and finish dates are necessary to show added work packages." }
      end
    end

    context "when the sprint has not started" do
      let(:started_at) { nil }

      include_examples "renders a blankslate" do
        let(:description) { "Added work packages will appear here after the sprint starts." }
      end
    end

    context "when nothing was added" do
      let(:added_after_start_ids) { [] }

      include_examples "renders a blankslate" do
        let(:description) { "Work packages that were added after the sprint start date will appear here." }
      end
    end

    context "when the sprint is running" do
      include_examples "renders a work packages table" do
        let(:timestamps) { "#{started_at.iso8601},PT0S" }
      end
    end

    context "when the sprint is complete" do
      let(:completed_at) { 1.hour.ago }

      include_examples "renders a work packages table" do
        let(:timestamps) { "#{started_at.iso8601},#{completed_at.iso8601}" }
      end
    end
  end
end
