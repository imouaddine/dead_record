require "spec_helper"
require 'dead_record'


describe DeadRecord do
  subject { Record.create() }


  after(:each) do
    ["Record", "NonDeadRecord", "Element", "MicroElement"].each do |o|
      Object.send(:remove_const, o)
    end
    load 'support/record.rb'
  end

  context "Dummy doesn't have deleted_at column" do
    it "raise an error when deleted_at is not present" do
      expect { NonDeadRecord.acts_as_dead_record }.to raise_error("NonDeadRecord should have a column named 'deleted_at'")
    end
  end
  describe "#dead_record?" do
    it { expect(NonDeadRecord.new).to_not be_dead_record }
    it { expect(Record.new).to be_dead_record }
  end

  describe "default scope" do

    context "override_default_scope is true (default)" do

      it "defines a default scope where deleted_at is nil" do
        record1 = Record.create!(:deleted_at => nil)
        Record.create!(:deleted_at => DateTime.now)
        record3 = Record.create!(:deleted_at => nil)

        expect(Record.all).to contain_exactly(record1, record3)

      end
    end

    context "override_default_scope is false (default)" do
      before {
        class DummyRecord < ActiveRecord::Base
          self.table_name = "records"

          acts_as_dead_record(override_default_scope: false)
        end
      }
      it "defines a default scope where deleted_at is nil" do
        record1 = DummyRecord.create!(:deleted_at => nil)
        record2 = DummyRecord.create!(:deleted_at => DateTime.now)
        record3 = DummyRecord.create!(:deleted_at => nil)

        expect(DummyRecord.all).to contain_exactly(record1, record2, record3)

      end
    end


  end

  describe "#delete" do
    it "touch deleted_at" do
     subject.delete
     expect(subject.deleted_at).to_not be_nil
    end
  end


  describe "#destroy" do

    it "doesn't delete the object" do
      subject
      expect {
        subject.destroy
      }.to change { Record.unscoped.count }.by(0)
    end


    it "set the value deleted_at to the current date" do
      subject.destroy
      expect(subject.deleted_at).to_not be_nil
    end

    context "#has_many association" do
      before {
        Record.class_eval do
          has_many :elements, dependent: :destroy
        end
      }
      it "soft delete elements as well" do
        subject.elements << Element.create
        subject.elements << Element.create
        expect {
          subject.destroy
        }.to change { subject.elements.count }.by(-2)
        expect(subject.elements.with_deleted.count).to eq 2
        expect(subject.elements.count).to eq 0
      end
    end
  end

  describe "#destroy_for_real" do
    it "delete the object" do
      subject
      expect {
        subject.destroy_for_real
      }.to change { Record.unscoped.count }.by(-1)
    end
  end

  describe "#callback before_destroy" do
    it "call the defined callback" do
      expect(subject).to receive(:some_method)

      class Record
        before_destroy :some_method
      end
      subject.destroy
    end
  end

  describe "#with_deleted" do
    it "includes deleted objects" do
      record1 = Record.create!(:deleted_at => nil)
      record2 = Record.create!(:deleted_at => DateTime.now)
      record3 = Record.create!(:deleted_at => nil)

      expect(Record.with_deleted).to contain_exactly(record1, record2, record3)
    end
  end

  describe "#only_deleted" do
    it "includes deleted objects" do
      Record.create!(:deleted_at => nil)
      record2 = Record.create!(:deleted_at => DateTime.now)
      Record.create!(:deleted_at => nil)

      expect(Record.only_deleted).to contain_exactly(record2)
    end
  end

  describe ".restore" do
    subject { Record.create!(:deleted_at => DateTime.now) }
    it "restore the destroyed element" do
      subject
      expect {
        Record.restore(subject.id)
      }.to change { Record.count }.by(1)
    end
    it "restore many objects at one" do
      subject
      record1 = Record.create!(:deleted_at => DateTime.now)
      record2 = Record.create!(:deleted_at => DateTime.now)
      record3 = Record.create!(:deleted_at => DateTime.now)

      expect {
        Record.restore(record1.id, record2.id, record3.id)
      }.to change { Record.count }.by(3)
    end


  end

  describe "#restore" do
    subject { Record.create!(:deleted_at => DateTime.now) }
    it "restore the destroyed element" do
      subject
      expect {
        subject.restore
      }.to change { Record.count }.by(1)
      expect(subject.deleted_at).to be_nil
    end


    context "include_association" do


      it "do not call restore associations when include_association is false " do
        expect(subject).to_not receive(:_restore_associations)
        subject.restore #include_association is false by default
      end

      it "do not call restore association on association which model is not a dead one" do
        subject.non_dead_records << NonDeadRecord.create
        subject.restore(include_association: true)
      end

      describe "#has_many assocation" do
        context "record with multiple elements" do
          before {
            subject.elements << Element.create(:deleted_at => DateTime.now)
            subject.elements << Element.create(:deleted_at => DateTime.now)
          }
          it "restore associations" do
            expect {
              subject.restore(include_association: true)
            }.to change { subject.elements.count }.by(2)
          end
          it "restore nested associations as well" do
            element = subject.elements.with_deleted.first
            element.micro_elements << MicroElement.create(:deleted_at => DateTime.now)
            element.micro_elements << MicroElement.create(:deleted_at => DateTime.now)
            expect {
              subject.restore(include_association: true)
            }.to change { element.reload.micro_elements.count }.by(2)
          end
        end

      end


      describe "#has_one assocation" do
        subject{ HasOneElementRecord.create(deleted_at: DateTime.now) }
        context "record with one element" do
          before {
            subject.element = Element.create(:deleted_at => DateTime.now)
          }
          it "restore associations" do
              subject.restore(include_association: true)
              expect(subject).to_not be_deleted
          end

        end

      end
    end

  end

  describe "#callback before_restore" do
    subject { Record.create!(:deleted_at => DateTime.now) }

    it "call the defined callback" do
      expect(subject).to receive(:some_method)
      Record.class_eval do
        before_restore :some_method
      end
      subject.restore
    end
  end


end
