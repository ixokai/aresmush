module AresMUSH
  module FS3Skills
    describe FS3Skills do

      before do
        Global.stub(:read_config).with("fs3skills", "max_xp_hoard") { 3 }
        SpecHelpers.stub_translate_for_testing
      end
      
      describe :award_xp do
        before do
          @char = Character.new(fs3_xp: 1)
        end
        
        it "should add xp" do
          @char.should_receive(:update).with(fs3_xp: 2)
          @char.award_xp(1)
        end

        it "should not go over the cap" do
          @char.should_receive(:update).with(fs3_xp: 3)
          @char.award_xp(5)
        end
      end
      
      describe :check_can_learn do
        before do
          @char = double
          Global.stub(:read_config).with("fs3skills", "max_points_on_attrs") { 14 }
          Global.stub(:read_config).with("fs3skills", "max_points_on_action") { 10 }
          Global.stub(:read_config).with("fs3skills", "dots_beyond_chargen_max") { 1 }
          FS3Skills.stub(:get_ability_type).with("Firearms") { :action }
        end
        
        it "should return false if next rating not in cost chart" do
          FS3Skills.should_receive(:xp_needed).with("Firearms", 4) { nil }
          FS3Skills.check_can_learn(@char, "Firearms", 4).should eq "fs3skills.cant_raise_further_with_xp"
        end
        
        it "should return false if char is at max in action already" do
          FS3Skills.should_receive(:xp_needed).with("Firearms", 4) { 4 }
          FS3Skills::AbilityPointCounter.stub(:points_on_action).with(@char) { 11 }
          FS3Skills.check_can_learn(@char, "Firearms", 4).should eq "fs3skills.max_ability_points_reached"
        end
        
        it "should return ok if char would be at max after spending on action" do
          FS3Skills.should_receive(:xp_needed).with("Firearms", 4) { 4 }
          FS3Skills::AbilityPointCounter.stub(:points_on_action).with(@char) { 10 }
          FS3Skills.check_can_learn(@char, "Firearms", 4).should eq nil
        end
        
        it "should return false if char is at max in attrs already" do
          FS3Skills.should_receive(:xp_needed).with("Firearms", 4) { 4 }
          FS3Skills.stub(:get_ability_type).with("Firearms") { :attribute }
          FS3Skills::AbilityPointCounter.stub(:points_on_attrs).with(@char) { 16 }
          FS3Skills.check_can_learn(@char, "Firearms", 4).should eq "fs3skills.max_ability_points_reached"
        end

        it "should return ok if char would be at max after spending on attrs" do
          FS3Skills.should_receive(:xp_needed).with("Firearms", 4) { 4 }
          FS3Skills.stub(:get_ability_type).with("Firearms") { :attribute }
          FS3Skills::AbilityPointCounter.stub(:points_on_attrs).with(@char) { 14 }
          FS3Skills.check_can_learn(@char, "Firearms", 4).should eq nil
        end
      end
      
      describe :xp do
        before do
          @char = Character.new(fs3_xp: 2)
        end
        
        it "should return xp" do
          @char.xp.should eq 2
        end
      end
    end
  end
end
