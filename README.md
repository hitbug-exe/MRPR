# MRPR
The code defines a simple implementation of the PageRank algorithm, which computes the importance of nodes in a directed graph based on the structure of the graph and the importance of the nodes that point to it.

The algorithm is implemented using the mapReduce function, which applies a mapping function (pageRankMap) to each key-value pair in a map representing the graph, then groups the resulting key-value pairs by key, and applies a reducing function (pageRankReduce) to each group to compute the new value for each key.

The pageRankMap function takes a pair of (node, list of outgoing edges) and an optional current page rank value for the node, and returns a list of pairs of (outgoing node, new page rank value) based on the current page rank value and the number of outgoing edges from the node. The pageRankReduce function takes a node and a list of page rank values for the node, and returns a new page rank value for the node based on the sum of the page rank values.

The main function defines the graph edges and the initial page rank values for each node, and uses the pageRank function to compute the final page rank values after a given number of steps. The toPageRankGraph function is a helper function that converts a list of edges and page rank values to a graph represented as a map.

To run the code, simply copy and paste it into a Haskell file and run it using GHCi or another Haskell interpreter. The final page rank values for all nodes will be printed to the console.

#References
https://static.googleusercontent.com/media/research.google.com/zh-CN//archive/mapreduce-osdi04.pdf
https://blogs.cornell.edu/info2040/2019/10/28/using-mapreduce-to-compute-pagerank/
https://medium.com/swlh/pagerank-on-mapreduce-55bcb76d1c99

