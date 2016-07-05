if not(MPI_Initialized) MPI_Init; end
CW = MPI_Comm_Load("NEWORLD");
node = MPI_Comm_rank(CW);
nodes = MPI_Comm_size(CW);
mytag = 48;


