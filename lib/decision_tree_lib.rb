#!/usr/bin/env ruby
require 'csv'
require 'sentimental'

module DecisionTreeLib
  def calculate_entropy examples
    entropy = 0
    classes = examples.group_by{|ex| ex["final_escalation_level"]}
    full_len = examples.length
    classes.keys.each do |class_val|
      pc = (classes[class_val].length) / full_len.to_f
      entropy += -(pc * Math.log(pc))
    end
    entropy
  end

  def calculate_info_gain examples, label, exclude
    features = examples[0].keys
    info_gain = {}
    features.each do |feat|
      if feat != label and !exclude.include? feat
        vals = {}
        examples.each { |ex| vals[ex[feat]] = (vals[ex[feat]] || 0.0) + 1.0 }
        sub_entropy = 0.0
        vals.each do |k,v|
          prob = v / vals.values.inject(:+)
          selected_ex = examples.select{|x| x[feat] == k }
          sub_entropy += prob * (calculate_entropy selected_ex)
        end
        info_gain[feat] = @entropy - sub_entropy
      end
    end
    Hash[info_gain.sort_by{|k,v| v}]
  end

  def get_customer_priority
    c_life = @examples.map{|x| x["customer_lifetime"].to_f }
    c_revenue = @examples.map{ |x| x["customer_revenue"].to_f }
    c_revenue = c_revenue.map{|x| x/c_revenue.max }
    c_life = c_life.map{|x| x/c_life.max }
    c_prio = c_revenue.map.with_index{ |x,v| (((x+c_life[v])*10)/2).to_i}
    @examples.each_with_index{|x,v| x["customer_priority"] = c_prio[v].to_s}
    @examples.map!{|x| x.reject!{|k,v| "customer_lifetime customer_revenue".include? k } }
    cust_prio = @examples.map{|x| [x["customer_name"], x["customer_priority"]]}.to_h
  end

  def build_tree examples, values, info_gain, tree, label, exclude
    subset_entropy = calculate_entropy(examples)
    if subset_entropy == 0.0 or info_gain.first[1] == 1.0
      children = {}
      tree.each do |key, val|
        prev_k = 0.0
        tree[key] = {}
        val.each do |k,v|
          tree[key][k] = examples[0][label]
          prev_k = k
        end
      end
    else
      tree.each do |key, val|
        val.each do |k, v|
          subset = examples.select{|x| x[key] == k}
          if subset.size >= 1
            exclude << key
            subset_info_gain = calculate_info_gain(subset, label, exclude)
            if subset_info_gain.size > 0
              tree[key][k] = {subset_info_gain.first[0] => Hash[values[subset_info_gain.first[0]].collect{|x| [x,0]}]}
              tree[key][k] = build_tree(subset, values, subset_info_gain, tree[key][k], label, exclude)
            else
              lstvalues = subset.collect{|x| x[label]}
              temp_h = Hash.new(0)
              lstvalues.each { |v| temp_h[v] += 1 }
              tree[key][k] = lstvalues.max_by{ |v| temp_h[v] }
            end
          else
            lstvalues = examples.collect{|x| x[label]}
            temp_h = Hash.new(0)
            lstvalues.each { |v| temp_h[v] += 1 }
            tree[key][k] = lstvalues.max_by{ |v| temp_h[v] }
          end
        end
      end
    end
    return tree
  end

  def predict tree, test
    analyzer = Sentimental.new
    analyzer.load_defaults
    analyzer.threshold = 0.3
    test["ticket_text"] = analyzer.sentiment(test["ticket_text"]).to_s
    begin
      while !tree.is_a? String do
        tree.each do |key, val|
          if test.keys.select{|x| x==key }
            tree = tree[key][test[key]]
          else
            tree = tree[key]
          end
        end
      end
    rescue => e
      tree = "Bad Request"
    end
    return tree
  end

  def decision_tree mode, file, label, exclude, id, user_id
    analyzer = Sentimental.new
    analyzer.load_defaults
    analyzer.threshold = 0.3
    csv = CSV::parse(File.open(file, 'r') {|f| f.read })
    fields = csv.shift
    fields = fields.map {|f| f.downcase.gsub(" ", "_")}
    @examples = csv.collect { |record| Hash[*fields.zip(record).flatten ] } 
    @examples = @examples.each{ |x| x["ticket_text"] = analyzer.sentiment(x["ticket_text"]).to_s}
    cust_prio = get_customer_priority
    features = @examples[0].keys
    core_features = features.delete_if { |item| item == exclude or item == label }
    values = Hash[core_features.collect{ |y| [y, @examples.map{|x| x[y]}.uniq] } ]
    @entropy = calculate_entropy @examples
    info_gain  = calculate_info_gain(@examples, label, [exclude, "related_product"])
    tree = {info_gain.first[0] => Hash[values[info_gain.first[0]].collect{|x| [x,0]}]}
    info_gain.delete(info_gain.first[0])
    tree = build_tree(@examples, values, info_gain, tree, label, [exclude, "related_product"])
    dt = DecisionTree.new({:tree => tree, :upload_id => id, :user_id => user_id, :customer_priority => cust_prio})
    dt.save
    puts tree
    puts dt.inspect
  end
end