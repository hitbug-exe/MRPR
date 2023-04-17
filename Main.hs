import Data.Map (Map, lookup, fromList, empty, insertWith, mapWithKey, filterWithKey, toList, insert)
import Data.List (sortBy)

-- | Maps a function over each key-value pair in a Map, then concatenates the resulting lists.
mapF :: Ord k2 => (k1 -> v1 -> [(k2, v2)]) -> Map k1 v1 -> [(k2, v2)]
mapF mapFunc m = [(k2, v2) | (k1, v1) <- toList m, (k2, v2) <- mapFunc k1 v1]


-- | Groups a list of key-value pairs by key, returning a Map of keys to lists of values.
group :: Ord k2 => [(k2, v2)] -> Map k2 [v2]
group = foldr insert empty where
  insert (k2, v2) dict = insertWith (++) k2 [v2] dict

-- | Reduces a Map of keys to lists of values to a Map of keys to reduced values.
reduce :: Ord k2 => (k2 -> [v2] -> Maybe v3) -> Map k2 [v2] -> Map k2 v3
reduce f = foldr combine empty . toList where
  combine (k, vs) acc = case f k vs of
    Just v -> insert k v acc
    Nothing -> acc

-- | Performs mapReduce on a given Map using the given map and reduce functions.
mapReduce :: Ord k2 => (k1 -> v1 -> [(k2, v2)]) -> (k2 -> [v2] -> Maybe v3) -> Map k1 v1 -> Map k2 v3 
mapReduce mapFunc reduceFunc = reduce reduceFunc . group . mapF mapFunc


-- | Maps a pair of (node, list of outgoing edges) to a list of pairs of (outgoing node, new page rank value).
-- If the current page rank value is not present (Nothing), returns an empty list.
pageRankMap :: (Integer, [Integer]) -> Maybe Double -> [(Integer, Double)]
pageRankMap outgoingEdges maybePageRank = case maybePageRank of
  Just pageRank -> map (\outgoingNode -> (outgoingNode, pageRank / d)) (snd outgoingEdges)
    where d = fromIntegral $ length (snd outgoingEdges)
  Nothing -> []

-- | Reduces a list of page rank values for a node to a new page rank value.
-- If the list of page rank values is empty, returns Nothing.
pageRankReduce :: Integer -> [Double] -> Maybe Double
pageRankReduce node pageRanks
  | null pageRanks = Nothing
  | otherwise = Just $ sum pageRanks

-- Define a custom comparison function
compareSecond :: (a, Maybe Double) -> (b, Maybe Double) -> Ordering
compareSecond (_, Just x) (_, Just y) = compare y x
compareSecond _ _ = error "Cannot compare tuples with missing values"

main = do
  -- Define the graph edges.
  let edges = [(1, [2, 3]), (2, [3]), (3, [1, 4]), (4, [2])]

  -- Define the initial page rank values for each node.
  let initialPageRanks = fromList $ map (\node -> (node, 0.25)) [1..4]
  
  -- Helper function that maps a list of edges and page rank values to a graph represented as a Map.
  let toPageRankGraph edges pageRanks = fromList $ map (\node -> (node, Data.Map.lookup (fst node) pageRanks)) edges
  
  -- Define the pageRank function using the pageRankMap and pageRankReduce functions.
  let pageRank = mapReduce pageRankMap pageRankReduce

  -- | Takes a list of edges and the number of steps to compute the page rank, and returns the final page rank values after the given number of steps.
  let pageRanksAfterSteps edges steps = iterate (toPageRankGraph edges . pageRank) (toPageRankGraph edges initialPageRanks) !! steps

  -- Calls the pageRanksAfterSteps function with steps=10 and edges=edges.
  let finalPageRanks = pageRanksAfterSteps edges 10

  -- Sort the list in descending order based on the second value
  let sortedList = sortBy compareSecond $ toList finalPageRanks

  -- Extract the first element of each tuple (i.e., the node IDs)
  let maxPagerankNodes = map fst sortedList
  
  -- Prints the finalPageRanks for all the nodes.
  mapM_ print maxPagerankNodes

