module HuskGame
  class HuskLayout
    attr_reader :nodes, :total_rooms, :breach_node_id, :data_core_node_id, :unlock_terminal_node_id

    OPPOSITE_SIDE = {
      north: :south,
      south: :north,
      east:  :west,
      west:  :east
    }.freeze

    SCALE_WEIGHTS = ([:large] * 5 + [:medium] * 4 + [:small] * 1 + [:tiny] * 1).freeze

    def initialize(initial_chaos:, initial_threat:)
      @nodes = {}
      @next_id = 0
      generate(initial_chaos, initial_threat)
    end

    def node(id)
      @nodes[id]
    end

    private

    def generate(initial_chaos, initial_threat)
      breach = create_node(
        scale: :large,
        chaos: initial_chaos,
        threat: initial_threat,
        depth: 0,
        is_breach: true
      )
      @breach_node_id = breach[:id]

      # BFS expansion — chaos increases each depth, naturally bounding the graph
      queue = [breach[:id]]
      while queue.any?
        current_id = queue.shift
        current = @nodes[current_id]

        [:north, :south, :east, :west].each do |side|
          next unless current[:connections][side].nil?
          next unless rand(4) + 2 > current[:chaos]

          new_depth = current[:depth] + 1
          neighbor = create_node(
            scale:   SCALE_WEIGHTS.sample,
            chaos:   current[:chaos] + 1,
            threat:  current[:threat] + 1,
            depth:   new_depth,
            is_breach: false
          )

          locked = [true, false].sample

          # Bidirectional link with shared lock state
          current[:connections][side] = { node_id: neighbor[:id], locked: locked }
          neighbor[:connections][OPPOSITE_SIDE[side]] = { node_id: current_id, locked: locked }

          queue << neighbor[:id]
        end
      end

      @total_rooms = @nodes.length
      designate_data_core
      designate_unlock_terminal
      ensure_solvable_path
    end

    def create_node(scale:, chaos:, threat:, depth:, is_breach:)
      id = @next_id
      @next_id += 1
      node = {
        id:           id,
        name:         is_breach ? 'breach' : "room_#{id}",
        scale:        scale,
        chaos:        chaos,
        threat:       threat,
        depth:        depth,
        is_breach:           is_breach,
        is_data_core:        false,
        is_unlock_terminal:  false,
        connections:  { north: nil, south: nil, east: nil, west: nil }
      }
      @nodes[id] = node
      node
    end

    def designate_data_core
      # Deepest non-breach node becomes the data core room
      candidates = @nodes.values.reject { |n| n[:is_breach] }
      return if candidates.empty?

      max_depth = candidates.map { |n| n[:depth] }.max
      deepest = candidates.select { |n| n[:depth] == max_depth }
      chosen = deepest.sample
      chosen[:is_data_core] = true
      @data_core_node_id = chosen[:id]
    end

    def designate_unlock_terminal
      # Pick a mid-depth node — not breach, not data core
      candidates = @nodes.values.reject { |n| n[:is_breach] || n[:is_data_core] }
      return if candidates.empty?

      max_depth = candidates.map { |n| n[:depth] }.max
      mid_depth = (max_depth / 2.0).ceil.clamp(1, max_depth)
      # Prefer nodes near the midpoint depth
      best = candidates.select { |n| n[:depth] == mid_depth }
      best = candidates.select { |n| n[:depth] >= mid_depth - 1 && n[:depth] <= mid_depth + 1 } if best.empty?
      best = candidates if best.empty?

      chosen = best.sample
      chosen[:is_unlock_terminal] = true
      @unlock_terminal_node_id = chosen[:id]
    end

    def ensure_solvable_path
      if @unlock_terminal_node_id
        # Guarantee unlocked path from breach to unlock terminal
        unlock_path(@breach_node_id, @unlock_terminal_node_id)
      else
        # No unlock terminal — force-unlock all doors so nothing is inaccessible
        unlock_all_doors
      end
    end

    def unlock_path(from_id, to_id)
      path = bfs_path(from_id, to_id)
      return unless path

      path.each_cons(2) do |a_id, b_id|
        a_node = @nodes[a_id]
        a_node[:connections].each do |side, conn|
          next unless conn && conn[:node_id] == b_id
          conn[:locked] = false
          b_node = @nodes[b_id]
          reverse = b_node[:connections][OPPOSITE_SIDE[side]]
          reverse[:locked] = false if reverse
        end
      end
    end

    def unlock_all_doors
      @nodes.each_value do |node|
        node[:connections].each_value do |conn|
          next unless conn
          conn[:locked] = false
        end
      end
    end

    def bfs_path(start_id, goal_id)
      visited = { start_id => nil }
      queue = [start_id]

      while queue.any?
        current_id = queue.shift
        return reconstruct_path(visited, goal_id) if current_id == goal_id

        @nodes[current_id][:connections].each do |_side, conn|
          next unless conn
          neighbor_id = conn[:node_id]
          next if visited.key?(neighbor_id)

          visited[neighbor_id] = current_id
          queue << neighbor_id
        end
      end

      nil # no path found (shouldn't happen in a connected graph)
    end

    def reconstruct_path(visited, goal_id)
      path = [goal_id]
      current = goal_id
      while visited[current]
        current = visited[current]
        path.unshift(current)
      end
      path
    end
  end
end
