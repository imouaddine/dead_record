require "dead_record/version"
require "active_record"
module DeadRecord


  def self.included(klass)
    klass.send :extend, ActsAsDeadRecord
    klass.class_eval do
      #false by default
      def dead_record?
        false
      end
    end
  end

  module ActsAsDeadRecord

    def acts_as_dead_record(options={})

      extend ClassMethods

      unless self.column_names.include?(column_name.to_s)
        raise "#{self.name} should have a column named '#{column_name}'"
      end

      default_scope { where(column_name => nil) } if options.fetch(:override_default_scope, true)

      class_eval do
        alias :destroy_for_real :destroy
        alias :deleted? :destroyed?
      end

      define_model_callbacks :restore

      include InstanceMethods

      instance_eval do
        private :restore_associations
      end
    end
  end

  module InstanceMethods
    def dead_record?
      true
    end

    def deleted?
      !!deleted_at
    end

    def delete
      touch(:deleted_at)
    end

    def destroy
      run_callbacks :destroy do
        touch(:deleted_at)
      end
    end

    def restore(include_association: false)
      run_callbacks :restore do
        self.transaction do
          update_column(:deleted_at, nil)
          restore_associations if include_association
        end
      end
    end

    private
    def restore_associations

      restore_block = lambda { |e| e.restore(include_association: true) if e.dead_record? && e.persisted? }
      self.class.reflect_on_all_associations.select { |a| a.options[:dependent] == :destroy }.each do |association|
        association_objects = self.send(association.name)
        if  association.collection?
          association_objects = association_objects.try(:only_deleted)
          if association_objects
            association_objects.each do |e|
              restore_block.call(e)
            end
          end
        else
          restore_block.call(association_objects)
        end
      end
    end
  end

  module ClassMethods

    def column_name
      :deleted_at
    end

    def with_deleted
      unscope where: column_name
    end

    def only_deleted
      unscoped.where.not(column_name => nil)
    end

    def restore(*ids, include_association: false)
      ActiveRecord::Base.transaction do
        with_deleted.find(ids).each do |r|
          r.restore
          r.restore_associations if include_association
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, DeadRecord)
