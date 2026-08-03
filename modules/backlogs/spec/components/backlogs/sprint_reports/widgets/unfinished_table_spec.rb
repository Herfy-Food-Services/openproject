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

RSpec.describe Backlogs::SprintReports::Widgets::UnfinishedTable,
               type: :component,
               with_ee: %i[baseline_comparison sprint_report_pro_widgets] do
  include_examples "sprint report work package table widget" do
    let(:widget_name) { "Unfinished work packages" }
    let(:unfinished_count) { 4 }
    let(:breakdown_overrides) do
      {
        done_status_ids: [3, 4],
        unfinished: SprintWorkPackageBreakdown::Block.new(work_package_count: unfinished_count, story_points: 0)
      }
    end
  end

  context "with all permissions and entitlements" do
    let(:filters) do
      [
        { sprintId: { operator: "=", values: [sprint.id.to_s] } },
        { status: { operator: "!", values: %w[3 4] } }
      ]
    end

    context "when the sprint has no dates set" do
      let(:start_date) { nil }
      let(:finish_date) { nil }

      include_examples "renders a blankslate" do
        let(:description) { "Sprint start and finish dates are necessary to show unfinished work packages." }
      end
    end

    context "when the sprint has not started" do
      let(:started_at) { nil }

      include_examples "renders a blankslate" do
        let(:description) { "Unfinished work packages will appear here after the sprint starts." }
      end
    end

    context "when everything is finished" do
      let(:unfinished_count) { 0 }

      include_examples "renders a blankslate" do
        let(:icon) { :trophy }
        let(:heading) { "Wow, all done!" }
        let(:description) { "All work packages in this sprint are completed." }
      end
    end

    context "when the sprint is running" do
      include_examples "renders a work packages table" do
        let(:timestamps) { nil }
      end
    end

    context "when the sprint is complete" do
      let(:completed_at) { 1.hour.ago }

      include_examples "renders a work packages table" do
        let(:timestamps) { completed_at.iso8601 }
      end
    end
  end
end
