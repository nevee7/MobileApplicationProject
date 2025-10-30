using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace AnimalFostering.API.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Animals",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Species = table.Column<string>(type: "text", nullable: false),
                    Breed = table.Column<string>(type: "text", nullable: false),
                    Age = table.Column<int>(type: "integer", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    ImageUrl = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Animals", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Animals",
                columns: new[] { "Id", "Age", "Breed", "CreatedAt", "Description", "ImageUrl", "Name", "Species", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, 2, "Siamese", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(2752), "Friendly and playful", "", "Whiskers", "Cat", "Available", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(2756) },
                    { 2, 3, "Golden Retriever", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(4624), "Loyal and energetic", "", "Buddy", "Dog", "Available", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(4624) }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Animals");
        }
    }
}
