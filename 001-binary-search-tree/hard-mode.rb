# My (hard mode) submission for challenge #1: "Binary Search Tree"
# https://medium.com/@jamis/weekly-programming-challenge-1-55b63b9d2a1
#
# This is an implementation of an AVL Tree--a kind of self-balancing
# binary search tree.
#
# As per hard-mode requirements, this implementation:
# * supports arbitrary data as keys (out-of-the-box if the data responds
#   to the <=> operator, otherwise you can supply a "comparison" function
#   to specify how the keys should be compared)
# * supports insert options
# * supports search options
# * supports delete options
# * implements a self-balancing binary tree
#
# - Jamis Buck
#   jamis@jamisbuck.org

class AVLTree
  class Node < Struct.new(:key, :value, :height, :parent, :left, :right)
    def recompute_height!
      self.height = [left ? left.height : 0, right ? right.height : 0].max + 1
      self.parent.recompute_height! if self.parent
    end

    def balance_factor
      left_height = left ? left.height : 0
      right_height = right ? right.height : 0
      right_height - left_height
    end

    def rotator
      left_heavy? ? left : right
    end

    def left_heavy?
      balance_factor < 0
    end

    def right_heavy?
      balance_factor > 0
    end

    def needed_rotation
      if balance_factor > 1
        if right.left_heavy?
          :right_left
        else
          :left
        end
      elsif balance_factor < -1
        if left.right_heavy?
          :left_right
        else
          :right
        end
      else
        nil
      end
    end

    def replace_child(old, new)
      if old == left
        self.left = new
      elsif old == right
        self.right = new
      end

      new.parent = self if new

      recompute_height!
    end

    def remove_child(child)
      replace_child(child, nil)
    end

    def inspect
      result = "[#{key}:#{value}"
      result << " L#{left.inspect}" if left
      result << " R#{right.inspect}" if right
      result << "]"
    end

    def visit(&block)
      left.visit(&block) if left
      block.call(self)
      right.visit(&block) if right
    end
  end

  def initialize(compare=->(a,b) { a <=> b })
    @root = nil
    @compare = compare
  end

  def [](key)
    node = _find(key)
    node && node.value
  end

  def []=(key, value)
    node = Node.new(key, value, 1)

    if @root.nil?
      @root = node
    else
      current = @root
      while true
        if @compare[node.key, current.key] < 0
          if current.left
            current = current.left
          else
            node.parent = current
            current.left = node
            break
          end
        elsif current.right
          current = current.right
        else
          node.parent = current
          current.right = node
          break
        end
      end
    end

    # correct heights
    node.recompute_height!

    _balance_from(node)
  end

  def delete(key)
    node = _find(key) or return
    _delete(node)

    node.value
  end

  def each
    if @root
      @root.visit { |node| yield node.key, node.value }
    end

    self
  end

  def _rotate_at(rotator)
    # from https://webdocs.cs.ualberta.ca/~holte/T26/tree-rotation.html
    # 'pivot' is the parent of the rotator node
    # 'parent' is parent of the 'pivot' node
    # 'inside' is the inside node of the rotator node
    #
    # Step 1. Prune pivot from its parent.
    # Step 2. Prune rotator from pivot.
    # Step 3. Prune inside from rotator.
    # Step 4. Join inside to pivot where rotator had been.
    # Step 5. Join pivot to the rotator where inside had been.
    # Step 6. Join rotator to parent where pivot had been.

    pivot = rotator.parent
    parent = pivot.parent

    rotator_direction = pivot.left == rotator ? :left : :right
    pivot_direction = parent.left == pivot ? :left : :right if parent
    inside_direction = rotator_direction == :left ? :right : :left

    inside = rotator.send(inside_direction)

    parent.remove_child(pivot) if parent # step 1
    pivot.remove_child(rotator)          # step 2
    rotator.remove_child(inside)         # step 3

    # step 4
    pivot.send(:"#{rotator_direction}=", inside)
    inside.parent = pivot if inside

    # step 5
    rotator.send(:"#{inside_direction}=", pivot)
    pivot.parent = rotator

    # step 6
    parent.send(:"#{pivot_direction}=", rotator) if parent
    rotator.parent = parent

    pivot.recompute_height!
    rotator.recompute_height!

    @root = rotator if parent.nil?

    rotator
  end

  def inspect
    @root ? @root.inspect : "[]"
  end

  def to_graphviz
    s = "graph avltree {\n"
    seen = {}

    stack = [ @root ].compact
    s << "  #{@root.key} [label=\"#{@root.key}:#{@root.value}\"]\n" if @root

    while stack.any?
      node = stack.shift

      if node.left
        stack.push node.left
        s << "  #{node.left.key} [label=\"#{node.left.key}:#{node.left.value}\"]\n"
        s << "  #{node.key} -- #{node.left.key}\n"
      else
        # invisible left-node
        s << "  #{node.key}left [shape=point]\n"
        s << "  #{node.key} -- #{node.key}left\n"
      end

      if node.right
        stack.push node.right
        s << "  #{node.right.key} [label=\"#{node.right.key}:#{node.right.value}\"]\n"
        s << "  #{node.key} -- #{node.right.key}\n"
      else
        # invisible right-node
        s << "  #{node.key}right [shape=point]\n"
        s << "  #{node.key} -- #{node.key}right\n"
      end
    end

    s << "}\n"

    s
  end

  def _find(key)
    current = @root

    while current
      case @compare[key, current.key]
      when  0 then return current
      when -1 then current = current.left
      when  1 then current = current.right
      end
    end

    nil
  end

  def _delete(node)
    parent = node.parent

    # node has both children
    if node.left && node.right
      # find minimum value in right-subtree
      n = node.right
      n = n.left while n.left

      # replace node with a copy of n
      new_n = Node.new(n.key, n.value, 1)

      node.left.parent = new_n
      node.right.parent = new_n
      new_n.left = node.left
      new_n.right = node.right
      new_n.recompute_height!

      node.parent.replace_child(node, new_n)

      # delete the old n node
      _delete(n)
    # node has one child...
    elsif node.left || node.right
      parent.replace_child(node, node.left || node.right)

    # node is a leaf-node (no children)
    elsif parent
      parent.remove_child(node)

    # deleting the only node in the tree
    else
      @root = nil
    end

    _balance_from(parent) if parent
  end

  def _balance_from(node)
    while node
      case node.needed_rotation
      when :left, :right then _rotate_at(node.rotator)
      when :left_right, :right_left then
        rotator = _rotate_at(node.rotator.rotator)
        _rotate_at(rotator)
      end

      node = node.parent
    end
  end
end

if $0 == __FILE__
  require 'minitest/autorun'

  class AVLTreeInsertingTest < Minitest::Test
    def setup
      @tree = AVLTree.new
    end

    def test_insert_root
      @tree['M'] = 1
      assert_equal "[M:1]", @tree.inspect
    end

    def test_insert_left_child
      @tree['M'] = 1
      @tree['A'] = 2
      assert_equal "[M:1 L[A:2]]", @tree.inspect
    end

    def test_insert_right_child
      @tree['M'] = 1
      @tree['Z'] = 2
      assert_equal "[M:1 R[Z:2]]", @tree.inspect
    end

    def test_insert_with_right_rotation
      @tree['M'] = 1  #       M   =>    G
      @tree['G'] = 2  #      /         / \
      @tree['B'] = 3  #     G         B   M
                      #    /
                      #   B
      assert_equal "[G:2 L[B:3] R[M:1]]", @tree.inspect
    end

    def test_insert_with_left_rotation
      @tree['M'] = 1  #   M          =>       T
      @tree['T'] = 2  #    \                 / \
      @tree['U'] = 3  #     T               M   U
                      #      \
                      #       U
      assert_equal "[T:2 L[M:1] R[U:3]]", @tree.inspect
    end

    def test_insert_with_right_left_rotation
      @tree['M'] = 1      #       M    =>   M       =>     S
      @tree['T'] = 2      #        \         \            / \
      @tree['S'] = 3      #         T         S          M   T
      @tree['R'] = 4      #        /         / \          \
                          #       S         R   T         R
                          #      /
                          #     R
      assert_equal "[S:3 L[M:1 R[R:4]] R[T:2]]", @tree.inspect
    end

    def test_insert_with_left_right_rotation
      @tree['M'] = 1    #    M     =>   M    =>    E
      @tree['B'] = 2    #   /          /          / \
      @tree['E'] = 3    #  B          E          B   M
      @tree['G'] = 4    #   \        / \            /
                        #    E      B   G          G
                        #     \
                        #      G

      assert_equal "[E:3 L[B:2] R[M:1 L[G:4]]]", @tree.inspect
    end
  end

  class AVLTreeSearchingTest < Minitest::Test
    # set up this tree:
    #               M
    #             /   \
    #            F     S
    #           / \   / \
    #          A   K P   Z
    def setup
      @tree = AVLTree.new
      %w( M F S A K P Z ).each { |v| @tree[v] = v.downcase.to_sym }
      expected = "[M:m L[F:f L[A:a] R[K:k]] R[S:s L[P:p] R[Z:z]]]"
      assert_equal expected, @tree.inspect
    end

    def test_find_root
      assert_equal :m, @tree["M"]
    end

    def test_find_intermediate_greater
      assert_equal :s, @tree["S"]
    end

    def test_find_intermediate_lesser
      assert_equal :f, @tree["F"]
    end

    def test_find_smallest_leaf
      assert_equal :a, @tree["A"]
    end

    def test_find_intermediate_leaf
      assert_equal :k, @tree["K"]
      assert_equal :p, @tree["P"]
    end

    def test_find_largest_leaf
      assert_equal :z, @tree["Z"]
    end

    def test_each_should_traverse_nodes_in_order
      accumulator = []
      @tree.each { |key, value| accumulator << "#{key}:#{value}" }
      assert_equal %w(A:a F:f K:k M:m P:p S:s Z:z), accumulator
    end

    def test_each_should_abort_with_break
      accumulator = []
      @tree.each { |key, value| accumulator << "#{key}:#{value}"; break }
      assert_equal %w(A:a), accumulator
    end
  end

  class AVLTreeDeletingTest < Minitest::Test
    # set up this tree:
    #              __M__
    #             /     \
    #            F       S
    #           / \     / \
    #          B   K   P   Y
    #         /   /\  /\   \
    #        A   G L N R   Z
    def setup
      @tree = AVLTree.new
      %w( M F S B K P Y A G L N R Z ).each { |v| @tree[v] = v.downcase.to_sym }
      expected = "[M:m L[F:f L[B:b L[A:a]] R[K:k L[G:g] R[L:l]]] R[S:s L[P:p L[N:n] R[R:r]] R[Y:y R[Z:z]]]]"
      assert_equal expected, @tree.inspect
    end

    def test_delete_solo_root
      tree = AVLTree.new
      tree["M"] = 1
      tree.delete("M")
      assert_equal "[]", tree.inspect
    end

    def test_delete_leaf
      @tree.delete("L")
      expected = "[M:m L[F:f L[B:b L[A:a]] R[K:k L[G:g]]] R[S:s L[P:p L[N:n] R[R:r]] R[Y:y R[Z:z]]]]"
      assert_equal expected, @tree.inspect
    end

    def test_delete_with_no_right_child
      @tree.delete("B")
      expected = "[M:m L[F:f L[A:a] R[K:k L[G:g] R[L:l]]] R[S:s L[P:p L[N:n] R[R:r]] R[Y:y R[Z:z]]]]"
      assert_equal expected, @tree.inspect
    end

    def test_delete_with_no_left_child
      @tree.delete("Y")
      expected = "[M:m L[F:f L[B:b L[A:a]] R[K:k L[G:g] R[L:l]]] R[S:s L[P:p L[N:n] R[R:r]] R[Z:z]]]"
      assert_equal expected, @tree.inspect
    end

    def test_delete_with_both_children_leaves
      @tree.delete("K")
      expected = "[M:m L[F:f L[B:b L[A:a]] R[L:l L[G:g]]] R[S:s L[P:p L[N:n] R[R:r]] R[Y:y R[Z:z]]]]"
      assert_equal expected, @tree.inspect
    end

    def test_delete_with_both_children_not_leaves
      @tree.delete("F")
      expected = "[M:m L[G:g L[B:b L[A:a]] R[K:k R[L:l]]] R[S:s L[P:p L[N:n] R[R:r]] R[Y:y R[Z:z]]]]"
      assert_equal expected, @tree.inspect
    end

    def test_delete_with_rebalance
      @tree.delete("G")
      @tree.delete("L")
      @tree.delete("K")

      expected = "[M:m L[B:b L[A:a] R[F:f]] R[S:s L[P:p L[N:n] R[R:r]] R[Y:y R[Z:z]]]]"
      assert_equal expected, @tree.inspect
    end
  end
end
