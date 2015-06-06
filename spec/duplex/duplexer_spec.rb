require "spec_helper"
require "duplex/datastore/factory_fake"

describe Duplex::Duplexer do
  let(:datastore) { Duplex::Datastore::Memory.new }
  let(:filestore) { Duplex::Filestore::Memory.new("/") }
  let(:factory) {
    factory = Duplex::Datastore::FactoryFake.new
    factory.set_datastore(datastore)
    factory
  }

  def create_duplexer
    duplex = Duplex::Duplexer.new(filestore: filestore, datastore_factory: factory)
    duplex.use_datastore("/datastore.msh")
    duplex
  end

  describe "any method call" do
    it "raises 'DatastoreNotSet' when the Datastore is not yet set" do
      duplex = Duplex::Duplexer.new(filestore: filestore, datastore_factory: factory)
      file_ref = create_file_ref
      expect(-> {duplex.all}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.duplicates}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.unique}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.incomplete}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.missing}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.keep([file_ref])}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.prefer([file_ref])}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.remove([file_ref])}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      relocate = -> {duplex.relocate([file_ref], file_ref.path, "/bar")}
      expect(relocate).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.drop([file_ref])}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.add_from_path("/")}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.add_from_datastore(datastore)}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.save!}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
      expect(-> {duplex.commit!}).to raise_error(Duplex::Duplexer::DatastoreNotSet)
    end
  end

  context "when selecting FileRefs" do
    let(:file_ref_1) { create_file_ref(sha: "123ABC") }
    let(:file_ref_2) { create_file_ref(sha: "123ABC") }
    let(:file_ref_3) { create_file_ref(sha: "456DEF") }
    let(:file_refs) { [file_ref_1, file_ref_2, file_ref_3] }

    def duplexer_with_file_refs(file_refs)
      datastore.add_file_refs(file_refs)
      create_duplexer
    end

    describe "#all" do
      it "returns a Selector with all FileRefs in the Datastore" do
        duplex = duplexer_with_file_refs(file_refs)
        spy = create_spy
        duplex.all.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array(file_refs.map(&:path))
      end
    end

    describe "#duplicates" do
      it "returns an iterator of duplicate FileRefs Selectors" do
        duplex = duplexer_with_file_refs(file_refs)
        expect(duplex.duplicates.count).to eql(1)
        datastore.add_file_refs([create_file_ref(sha: file_ref_3.sha)])
        expect(duplex.duplicates.count).to eql(2)
      end

      it "Selectors yield duplicate FileRef from the Datastore" do
        duplex = duplexer_with_file_refs(file_refs)
        spy = create_spy
        duplex.duplicates.first.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array([file_ref_1.path, file_ref_2.path])
      end
    end

    describe "#unique" do
      it "returns a Selector with unique FileRefs in the Datastore" do
        duplex = duplexer_with_file_refs(file_refs)
        spy = create_spy
        duplex.unique.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array([file_ref_3.path])
      end
    end

    describe "#incomplete" do
      it "returns a Selector with incomplete FileRefs in the Datastore" do
        incompletes = [create_file_ref(sha: nil, size: nil), create_file_ref(sha: nil, size: nil)]
        duplex = duplexer_with_file_refs(file_refs + incompletes)
        spy = create_spy
        duplex.incomplete.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array(incompletes.map(&:path))
      end
    end

    describe "#missing" do
      it "returns a Selector with missing FileRefs in the Datastore" do
        duplex = duplexer_with_file_refs(file_refs)
        filestore.add_file(file_ref_2)
        spy = create_spy
        duplex.missing.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array([file_ref_1.path, file_ref_3.path])
      end
    end
  end

  context "when setting decisions" do
    describe "#keep" do
      let(:file_ref_1) { create_file_ref }
      let(:file_ref_2) { create_file_ref }

      before(:each) do
        datastore.add_file_refs([file_ref_1, file_ref_2])
      end

      it "sets :decision to :keep on the given FileRefs" do
        create_duplexer.keep([file_ref_1, file_ref_2])
        expect(file_ref_1.decision).to eql(:keep)
        expect(file_ref_2.decision).to eql(:keep)
      end

      it "sets :decision to :keep on the stored instances of the given FileRefs" do
        create_duplexer.keep([file_ref_1, file_ref_2])
        expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:keep)
        expect(datastore.find_by_path(file_ref_2.path).decision).to eql(:keep)
      end

      it "reassigns :decision on both instances" do
        datastore.update(file_ref_1, decision: :prefer)
        create_duplexer.keep([file_ref_1])
        expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:keep)
      end

      it "ignores FileRefs not already stored in the datastore" do
        file_ref_3 = create_file_ref
        create_duplexer.keep([file_ref_3])
        expect(datastore.find_by_path(file_ref_3.path)).to be_nil
      end
    end

    describe "#prefer" do
      let(:file_ref_1) { create_file_ref }
      let(:file_ref_2) { create_file_ref }

      before(:each) do
        datastore.add_file_refs([file_ref_1, file_ref_2])
      end

      it "sets :decision to :prefer on the given FileRefs" do
        create_duplexer.prefer([file_ref_1, file_ref_2])
        expect(file_ref_1.decision).to eql(:prefer)
        expect(file_ref_2.decision).to eql(:prefer)
      end

      it "sets :decision to :prefer on the stored instances of the given FileRefs" do
        create_duplexer.prefer([file_ref_1, file_ref_2])
        expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:prefer)
        expect(datastore.find_by_path(file_ref_2.path).decision).to eql(:prefer)
      end

      it "reassigns :decision on both instances" do
        datastore.update(file_ref_1, decision: :keep)
        create_duplexer.prefer([file_ref_1])
        expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:prefer)
      end

      it "ignores FileRefs not already stored in the datastore" do
        file_ref_3 = create_file_ref
        create_duplexer.prefer([file_ref_3])
        expect(datastore.find_by_path(file_ref_3.path)).to be_nil
      end
    end

    describe "#remove" do
      let(:file_ref_1) { create_file_ref }
      let(:file_ref_2) { create_file_ref }

      before(:each) do
        datastore.add_file_refs([file_ref_1, file_ref_2])
      end

      it "sets :decision to :remove on the given FileRefs" do
        create_duplexer.remove([file_ref_1, file_ref_2])
        expect(file_ref_1.decision).to eql(:remove)
        expect(file_ref_2.decision).to eql(:remove)
      end

      it "sets :decision to :remove on the stored instances of the given FileRefs" do
        create_duplexer.remove([file_ref_1, file_ref_2])
        expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:remove)
        expect(datastore.find_by_path(file_ref_2.path).decision).to eql(:remove)
      end

      it "reassigns :decision on both instances" do
        datastore.update(file_ref_1, decision: :keep)
        create_duplexer.remove([file_ref_1])
        expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:remove)
      end

      it "ignores FileRefs not already stored in the datastore" do
        file_ref_3 = create_file_ref
        create_duplexer.remove([file_ref_3])
        expect(datastore.find_by_path(file_ref_3.path)).to be_nil
      end
    end

    describe "#relocate" do
      let(:file_ref_1) { create_file_ref(location: "/example/path") }
      let(:file_ref_2) { create_file_ref(location: "/nested/example/path") }
      let(:file_ref_3) { create_file_ref(location: "/sample/path") }

      it "sets the :destination for FileRefs matching the given path" do
        file_refs = [file_ref_1, file_ref_2]
        datastore.add_file_refs(file_refs)
        create_duplexer.relocate(file_refs, "example", "relocated")
        expect(datastore.find_by_path(file_ref_1.path).destination).to include("/relocated/path")
        expect(datastore.find_by_path(file_ref_2.path).destination).to include("/nested/relocated/path")
      end

      it "ignores FileRefs not matching the given path" do
        file_refs = [file_ref_1, file_ref_2, file_ref_3]
        datastore.add_file_refs(file_refs)
        create_duplexer.relocate(file_refs, "example", "relocated")
        expect(datastore.find_by_path(file_ref_3.path).destination).to be_nil
      end

      it "accepts regular expressions" do
        file_refs = [file_ref_1, file_ref_2]
        datastore.add_file_refs(file_refs)
        create_duplexer.relocate(file_refs, /example/, "relocated")
        expect(datastore.find_by_path(file_ref_1.path).destination).to include("/relocated/path")
        expect(datastore.find_by_path(file_ref_2.path).destination).to include("/nested/relocated/path")
      end

      it "can use regular expressions for greater precision" do
        file_refs = [file_ref_1, file_ref_2]
        datastore.add_file_refs(file_refs)
        create_duplexer.relocate(file_refs, /^\/example/, "/relocated")
        expect(datastore.find_by_path(file_ref_1.path).destination).to include("/relocated/path")
        expect(datastore.find_by_path(file_ref_2.path).destination).to be_nil
      end

      it "overwrites existing :destinations" do
        file_refs = [file_ref_1, file_ref_2]
        datastore.add_file_refs(file_refs)
        create_duplexer.relocate(file_refs, "example", "relocated")
        create_duplexer.relocate(file_refs, "example", "elsewhere")
        expect(datastore.find_by_path(file_ref_1.path).destination).to include("/elsewhere/path")
        expect(datastore.find_by_path(file_ref_2.path).destination).to include("/nested/elsewhere/path")
      end
    end

    describe "#drop" do
      let(:file_ref_1) { create_file_ref }
      let(:file_ref_2) { create_file_ref }

      it "removes the given FileRefs from the Datastore" do
        datastore.add_file_refs([file_ref_1, file_ref_2])
        create_duplexer.drop([file_ref_1, file_ref_2])
        expect(datastore.exists?(file_ref_1)).to eql(false)
        expect(datastore.exists?(file_ref_2)).to eql(false)
      end

      it "has no effect on other FileRefs in the Datastore" do
        datastore.add_file_refs([file_ref_1, file_ref_2])
        create_duplexer.drop([file_ref_2])
        expect(datastore.exists?(file_ref_1)).to eql(true)
        expect(datastore.exists?(file_ref_2)).to eql(false)
      end

      it "has no effect when given FileRefs not present in the Datastore" do
        datastore.add_file_refs([file_ref_1, file_ref_2])
        create_duplexer.drop([create_file_ref, file_ref_2])
        expect(datastore.exists?(file_ref_2)).to eql(false)
      end
    end
  end

  context "when adding FileRefs" do
    describe "#add_from_path" do
      it "adds FileRefs from the given path in the Filestore" do
        file_ref = create_file_ref(location: "/example")
        filestore.add_file(file_ref)
        create_duplexer.add_from_path(file_ref.location)
        expect(datastore.find_by_path(file_ref.path)).to_not be_nil
      end
    end

    describe "#add_from_datastore" do
      it "adds FileRefs from the given datastore" do
        file_ref = create_file_ref
        other_datastore = Duplex::Datastore::Memory.new
        other_datastore.add_file_refs([file_ref])
        create_duplexer.add_from_datastore(other_datastore)
        expect(datastore.find_by_path(file_ref.path)).to_not be_nil
      end
    end
  end

  context "when persisting changes" do
    describe "#save!" do
      it "saves changes to the Datastore" do
        datastore.add_file_refs([create_file_ref, create_file_ref])
        expect(datastore.unsaved_changes?).to eql(true)
        create_duplexer.save!
        expect(datastore.unsaved_changes?).to eql(false)
      end
    end

    describe "#commit!" do
      let(:file_ref_1) { create_file_ref(path: "/example/file.txt", destination: "/sample/file.txt") }
      let(:file_ref_2) { create_file_ref(path: "/sample/file.doc", destination: "/example/file.doc") }

      it "moves the file at each FileRef :path to the FileRef's :destination" do
        datastore.add_file_refs([file_ref_1, file_ref_2])
        filestore.add_file(file_ref_1)
        filestore.add_file(file_ref_2)
        create_duplexer.commit!
        expect(filestore.file_exists?(file_ref_1)).to eql(false)
        expect(filestore.file_exists?(file_ref_2)).to eql(false)
        expect(filestore.file_exists?(create_file_ref(path: file_ref_1.destination))).to eql(true)
        expect(filestore.file_exists?(create_file_ref(path: file_ref_2.destination))).to eql(true)
      end

      it "updates the FileRef in the Datastore" do
        datastore.add_file_refs([file_ref_1])
        filestore.add_file(file_ref_1)
        create_duplexer.commit!
        expect(datastore.find_by_path(file_ref_1.path)).to be_nil
        expect(datastore.find_by_path(file_ref_1.destination)).to_not be_nil
      end

      it "ignores FileRefs without a :destination" do
        file_ref = create_file_ref(path: "/example/file.txt")
        datastore.add_file_refs([file_ref])
        filestore.add_file(file_ref)
        create_duplexer.commit!
        expect(datastore.find_by_path(file_ref.path)).to_not be_nil
        expect(datastore.find_by_path(file_ref.destination)).to be_nil
      end

      it "does not explode for files that do not exist" do
        datastore.add_file_refs([file_ref_1])
        create_duplexer.commit!
        expect(datastore.find_by_path(file_ref_1.path)).to_not be_nil
        expect(datastore.find_by_path(file_ref_1.destination)).to be_nil
      end
    end
  end

  context "when managing Datastores" do
    describe "#use_datastore" do
      let(:path) { tmp_path("/exported.msh") }
      let(:file_refs) { [create_file_ref, create_file_ref] }

      it "gets the Datastore at the given path" do
        factory.set_datastore(nil)
        datastore = create_duplexer.use_datastore(path)
        expect(datastore.path).to eql(path)
      end

      it "uses the Datastore for other behaviors" do
        source_datastore = Duplex::Datastore::Memory.new
        source_datastore.add_file_refs(file_refs)
        duplex = Duplex::Duplexer.new(filestore: filestore, datastore_factory: factory)
        datastore = duplex.use_datastore(path)
        duplex.add_from_datastore(source_datastore)
        expect(datastore.count).to eql(2)
        expect(datastore.to_a.map(&:path)).to match_array(file_refs.map(&:path))
      end
    end

    describe "#export_to_datastore" do
      let(:file_refs) { [create_file_ref, create_file_ref] }

      it "uses the Datastore at the given path" do
        factory.set_datastore(nil)
        path = tmp_path("/exported.msh")
        datastore = create_duplexer.export_to_datastore(file_refs, path)
        expect(datastore.path).to eql(path)
      end

      it "exports the given FileRefs to the Datastore" do
        create_duplexer.export_to_datastore(file_refs, tmp_path("/exported.msh"))
        expect(datastore.count).to eql(2)
        expect(datastore.to_a.map(&:path)).to match_array(file_refs.map(&:path))
      end

      it "saves the Datastore" do
        create_duplexer.export_to_datastore(file_refs, tmp_path("/exported.msh"))
        expect(datastore.unsaved_changes?).to eql(false)
      end
    end
  end
end
